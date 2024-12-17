//  DependencyFinder.swift

import Foundation

final class DependencyFinder {

    enum DependencyFinderError: Error, LocalizedError {
        case failedCollectingDependencies(packageUrl: URL)

        var errorDescription: String? {
            switch self {
            case .failedCollectingDependencies(let packageUrl):
                return "Failed collecting dependencies at \(packageUrl.path)"
            }
        }
    }

    private let fileManager: FileManager

    private lazy var dependencyHasher: DependencyHasher = {
        DependencyHasher(fileManager: fileManager)
    }()

    // MARK: - Inits

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    // MARK: - Functions

    func findPackageDependencies(at url: URL, requiredHashingPaths: [String], optionalHashingPaths: [String] = []) async throws -> [PackageDependency] {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/swift", directoryHint: .notDirectory)
        process.arguments = ["package", "show-dependencies", "--format", "json"]
        process.currentDirectoryURL = url

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
            requiredHashingPaths: requiredHashingPaths,
            optionalHashingPaths: optionalHashingPaths
        )
    }

    // MARK: - Helper Functions

    private func parseDependencies(_ dependencies: [DependencySpec], requiredHashingPaths: [String], optionalHashingPaths: [String] = []) throws -> [PackageDependency] {
        var result = [PackageDependency]()

        for dependency in dependencies {
            if dependency.version == "unspecified" {
                let url = URL(filePath: dependency.path, directoryHint: .isDirectory)
                let hash = try dependencyHasher.hashForPackage(
                    at: url,
                    requiredSubpaths: requiredHashingPaths,
                    optionalSubpaths: optionalHashingPaths
                )
                result.append(
                    PackageDependency(
                        name: dependency.name,
                        type: .local(hash: hash)
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
                requiredHashingPaths: requiredHashingPaths,
                optionalHashingPaths: optionalHashingPaths
            )
            result.append(contentsOf: nestedDependencies)
        }

        return Set(result)
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
}
