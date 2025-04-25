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
    private let dependencyFinder: DependencyFinding

    private let writer: Writing
    private let fileManager: FileManager
    
    init(templateUrl: URL, dependenciesUrl: URL, dependencyFinder: DependencyFinding, writer: Writing, fileManager: FileManager = .default) {
        self.templateUrl = templateUrl
        self.dependenciesUrl = dependenciesUrl
        self.dependencyFinder = dependencyFinder
        self.writer = writer
        self.fileManager = fileManager
    }

    @discardableResult
    func generatePackage(at outputUrl: URL, filename: String, specUrl: URL, dependencyTreatment: DependencyTreatment) async throws -> Path {
        let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: dependenciesUrl)
        let content = try ContentGenerator().content(for: spec, templateUrl: templateUrl)
        let outputFilePath = try writer.write(
            content: content,
            folder: outputUrl,
            filename: filename
        )
        print("✅ File successfully saved at \(outputFilePath.path).")

        switch dependencyTreatment {
        case .standard:
            return outputFilePath
        case .binaryTargets(let relativeDependenciesPath, let versionRefsPath, let exclusions):
            print("✅ Converting \(outputFilePath) to use dependencies as binary targets.")
            let packageConvertor = PackageConvertor()
            let convertedSpec = try await packageConvertor.convertDependenciesToBinaryTargets(
                dependencyFinder: dependencyFinder,
                spec: spec,
                packageFileUrl: outputFilePath,
                relativeDependenciesPath: relativeDependenciesPath,
                versionRefsPath: versionRefsPath,
                exclusions: exclusions
            )
            let content = try ContentGenerator().content(for: convertedSpec, templateUrl: templateUrl)
            let path = try writer.write(
                content: content,
                folder: outputUrl,
                filename: filename
            )
            print("✅ File successfully updated at \(path).")
            return path
        }
    }

    @discardableResult
    func generateTuistPackage(at outputUrl: URL, modulesPath: String, localModuleLister: LocalModuleListing) async throws -> Path {
        let dependencies: Dependencies = try DTOLoader().loadDTO(url: dependenciesUrl)
        let localModules = try localModuleLister.listLocalModules(at: modulesPath)

        let content = try ContentGenerator().content(
            for: dependencies,
            localModules: localModules,
            templateUrl: templateUrl
        )
        let outputFilePath = try writer.write(
            content: content,
            folder: outputUrl,
            filename: Constants.packageFile
        )
        print("✅ File successfully saved at \(outputFilePath.path).")
        return outputFilePath
    }
}
