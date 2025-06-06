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
        packageFileUrl: URL,
        relativeDependenciesPath: String,
        versionRefsPath: String,
        exclusions: [String]
    ) async throws -> Spec {
        let packageLocation = packageFileUrl.deletingLastPathComponent()
        let dependencies = try await dependencyFinder.findPackageDependencies(
            at: packageLocation,
            versionRefsPath: versionRefsPath
        )

        let additionalLocalBinaryTargets: [Spec.LocalBinaryTarget] = dependencies.compactMap { dependency in
            if exclusions.contains(dependency.name) { return nil }
            let localBinaryPath = [
                relativeDependenciesPath,
                dependency.name,
                dependency.revision,
                "\(dependency.name).xcframework"
            ].joined(separator: "/")
            return Spec.LocalBinaryTarget(
                name: dependency.name,
                path: localBinaryPath
            )
        }

        return spec.cachableSpec(additionalLocalBinaryTargets: additionalLocalBinaryTargets, exclusions: exclusions)
    }
}
