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

    private let specUrl: URL
    private let templateUrl: URL
    private let dependenciesUrl: URL

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
            let path = try write(content: try ContentGenerator().content(for: convertedSpec, templateUrl: templateUrl))
            print("✅ File successfully updated at \(path).")
        }
    }

    private func write(content: Content) throws -> String {
        try Writer().writePackageFile(content: content, to: specUrl.deletingLastPathComponent())
    }
}
