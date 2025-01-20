//  PackageConvertor.swift

import Foundation

struct PackageConvertor {

    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func convertDependenciesToBinaryTargets(
        dependencyFinder: DependencyFinding,
        spec: Spec,
        packageFilePath: String,
        relativeDependenciesPath: String,
        versionRefsPath: String,
        exclusions: [String]
    ) async throws -> Spec {
        let packageLocation = URL(filePath: packageFilePath).deletingLastPathComponent()
        let dependencies = try await dependencyFinder.findPackageDependencies(
            at: packageLocation,
            versionRefsPath: versionRefsPath
        )

        let additionalLocalBinaryTargets: [Spec.LocalBinaryTarget] = dependencies.compactMap { dependency in
            if exclusions.contains(dependency.name) { return nil }
            return Spec.LocalBinaryTarget(
                name: dependency.name,
                path: "\(relativeDependenciesPath)/\(dependency.name)/\(dependency.revision)/\(dependency.name).xcframework"
            )
        }

        return spec.cachableSpec(additionalLocalBinaryTargets: additionalLocalBinaryTargets, exclusions: exclusions)
    }
}
