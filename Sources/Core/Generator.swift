//  Generator.swift

import Foundation

struct Generator {

    enum DependencyTreatment {
        case standard
        case binaryTargets(
            relativeDependenciesPath: String,
            requiredHashingPaths: [String],
            optionalHashingPaths: [String],
            exclusions: [String]
        )
    }

    private var specUrl: URL
    private var templateUrl: URL
    private var dependenciesUrl: URL

    private let fileManager: FileManager
    
    init(specUrl: URL, templateUrl: URL, dependenciesUrl: URL, fileManager: FileManager = .default) {
        self.specUrl = specUrl
        self.templateUrl = templateUrl
        self.dependenciesUrl = dependenciesUrl
        self.fileManager = fileManager
    }

    func generatePackage(dependencyTreatment: DependencyTreatment) async throws {
        let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: dependenciesUrl)

        let path = try write(content: try ContentGenerator().content(for: spec, templateUrl: templateUrl))
        print("✅ File successfully saved at \(path).")

        switch dependencyTreatment {
        case .standard:
            break
        case .binaryTargets(let relativeDependenciesPath, let requiredHashingPaths, let optionalHashingPaths, let exclusions):
            print("✅ Converting \(path) to use dependencies as binary targets.")
            try await convertDependenciesToBinaryTargets(
                spec: spec,
                packageFilePath: path,
                relativeDependenciesPath: relativeDependenciesPath,
                requiredHashingPaths: requiredHashingPaths,
                optionalHashingPaths: optionalHashingPaths,
                exclusions: exclusions
            )
        }
    }

    // MARK: - Helper Functions

    private func convertDependenciesToBinaryTargets(
        spec: Spec,
        packageFilePath: String,
        relativeDependenciesPath: String,
        requiredHashingPaths: [String],
        optionalHashingPaths: [String],
        exclusions: [String]
    ) async throws {
        let dependencyFinder = DependencyFinder(fileManager: fileManager)
        let packageLocation = URL(filePath: packageFilePath).deletingLastPathComponent()
        let dependencies = try await dependencyFinder.findPackageDependencies(
            at: packageLocation,
            requiredHashingPaths: requiredHashingPaths,
            optionalHashingPaths: optionalHashingPaths
        )

        let additionalLocalBinaryTargets: [Spec.LocalBinaryTarget] = dependencies.compactMap { dependency in
            if exclusions.contains(dependency.name) { return nil }
            return Spec.LocalBinaryTarget(
                name: dependency.name,
                path: "\(relativeDependenciesPath)/\(dependency.name)/\(dependency.revision)/\(dependency.name).xcframework"
            )
        }

        let cachableSpec = spec.cachableSpec(additionalLocalBinaryTargets: additionalLocalBinaryTargets, exclusions: exclusions)
        let path = try write(content: try ContentGenerator().content(for: cachableSpec, templateUrl: templateUrl))
        print("✅ File successfully updated at \(path).")
    }

    private func write(content: Content) throws -> String {
        try Writer().writePackageFile(content: content, to: specUrl.deletingLastPathComponent())
    }
}
