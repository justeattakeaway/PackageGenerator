//  DependencyFinder.swift

import Foundation

final class DependencyFinder {

    enum DependencyFinderError: Error, LocalizedError {
        case failedCollectingDependencies(packageUrl: URL)
        case missingVersionRef(dependency: String)

        var errorDescription: String? {
            switch self {
            case .failedCollectingDependencies(let packageUrl):
                return "Failed collecting dependencies at \(packageUrl.path)"
            case .missingVersionRef(let dependency):
                return "Missing versionRef for \(dependency)"
            }
        }
    }

    private let fileManager: FileManager

    // MARK: - Inits

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    // MARK: - Functions

    func findPackageDependencies(at url: URL, versionRefsPath: String) async throws -> [PackageDependency] {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/swift", directoryHint: .notDirectory)
        process.arguments = ["package", "show-dependencies", "--format", "json"]
        process.currentDirectoryURL = url.absoluteURL

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw DependencyFinderError.failedCollectingDependencies(packageUrl: url)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let packageDescription = try JSONDecoder().decode(PackageSpec.self, from: data)
        return try parseDependencies(
            packageDescription.dependencies,
            versionRefsPath: versionRefsPath
        )
    }

    // MARK: - Helper Functions

    private func parseDependencies(_ dependencies: [DependencySpec], versionRefsPath: String) throws -> [PackageDependency] {
        var result = [PackageDependency]()
        let dependencyReferences = try loadDependencyReferences(from: versionRefsPath)

        for dependency in dependencies {
            if dependency.version == "unspecified" {
                guard let versionRef = dependencyReferences.first(where: { dep in
                    dep.name == dependency.name
                })?.versionRef else {
                    throw DependencyFinderError.missingVersionRef(dependency: dependency.name)
                }
                result.append(
                    PackageDependency(
                        name: dependency.name,
                        type: .local(hash: versionRef)
                    )
                )
            }
            else {
                result.append(
                    PackageDependency(
                        name: dependency.name,
                        type: .remote(tag: dependency.version)
                    )
                )
            }

            let nestedDependencies = try parseDependencies(
                dependency.dependencies,
                versionRefsPath: versionRefsPath
            )
            result.append(contentsOf: nestedDependencies)
        }

        return Set(result)
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    private func loadDependencyReferences(from filePath: String) throws -> [DependencyReference] {
        let file = URL(filePath: filePath, directoryHint: .notDirectory)
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(DependenciesFile.self, from: data).dependencies
    }
}
