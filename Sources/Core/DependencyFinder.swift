//  DependencyFinder.swift

import Foundation

final class DependencyFinder: DependencyFinding {

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
        var result = Set<PackageDependency>()
        let dependencyReferences = try loadDependencyReferences(from: versionRefsPath)

        for dependency in dependencies {
            let type: PackageDependency.PackageDependencyType = try {
                if dependency.version == "unspecified" {
                    guard let versionRef = dependencyReferences.first(where: { dep in
                        dep.name == dependency.name
                    })?.versionRef else {
                        throw DependencyFinderError.missingVersionRef(dependency: dependency.name)
                    }
                    return .local(hash: versionRef)
                }
                else {
                    return .remote(tag: dependency.version)
                }
            }()

            result.insert(
                PackageDependency(
                    name: dependency.name,
                    type: type
                )
            )

            let nestedDependencies = try parseDependencies(
                dependency.dependencies,
                versionRefsPath: versionRefsPath
            )
            result.formUnion(nestedDependencies)
        }

        return result
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    private func loadDependencyReferences(from filePath: String) throws -> [DependencyReference] {
        let file = URL(filePath: filePath, directoryHint: .notDirectory)
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(DependenciesFile.self, from: data).dependencies
    }
}
