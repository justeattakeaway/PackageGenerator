//  Generator.swift

import Foundation

struct Generator {

    enum DependencyTreatment {
        case standard
        case binaryTargets(
            relativeDependenciesPath: String,
            versionRefsPath: String,
            exclusions: [String]
        )
    }

    private let templateUrl: URL
    private let dependenciesUrl: URL

    private let fileManager: FileManager
    
    init(templateUrl: URL, dependenciesUrl: URL, fileManager: FileManager = .default) {
        self.templateUrl = templateUrl
        self.dependenciesUrl = dependenciesUrl
        self.fileManager = fileManager
    }

    func generatePackage(specUrl: URL, dependencyTreatment: DependencyTreatment) async throws {
        let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: dependenciesUrl)
        let content = try ContentGenerator().content(for: spec, templateUrl: templateUrl)
        let path = try Writer().writePackageFile(content: content, to: specUrl.deletingLastPathComponent())
        print("✅ File successfully saved at \(path).")

        switch dependencyTreatment {
        case .standard:
            break
        case .binaryTargets(let relativeDependenciesPath, let versionRefsPath, let exclusions):
            print("✅ Converting \(path) to use dependencies as binary targets.")
            let packageConvertor = PackageConvertor()
            let convertedSpec = try await packageConvertor.convertDependenciesToBinaryTargets(
                dependencyFinder: DependencyFinder(fileManager: fileManager),
                spec: spec,
                packageFilePath: path,
                relativeDependenciesPath: relativeDependenciesPath,
                versionRefsPath: versionRefsPath,
                exclusions: exclusions
            )
            let content = try ContentGenerator().content(for: convertedSpec, templateUrl: templateUrl)
            let path = try Writer().writePackageFile(content: content, to: specUrl.deletingLastPathComponent())
            print("✅ File successfully updated at \(path).")
        }
    }
}
