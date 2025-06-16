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
    private let packageDependenciesUrl: URL
    private let dependencyFinder: DependencyFinding

    private let writer: Writing
    private let fileManager: FileManager
    
    init(templateUrl: URL, packageDependenciesUrl: URL, dependencyFinder: DependencyFinding, writer: Writing, fileManager: FileManager) {
        self.templateUrl = templateUrl
        self.packageDependenciesUrl = packageDependenciesUrl
        self.dependencyFinder = dependencyFinder
        self.writer = writer
        self.fileManager = fileManager
    }

    @discardableResult
    func generatePackage(at outputUrl: URL, filename: String, specUrl: URL, dependencyTreatment: DependencyTreatment, useRegistry: Bool) async throws -> Path {
        let spec = try SpecGenerator().makeSpec(
            specUrl: specUrl,
            dependenciesUrl: packageDependenciesUrl,
            useRegistry: useRegistry
        )
        let content = try ContentGenerator().content(
            for: spec,
            templateUrl: templateUrl,
            useRegistry: useRegistry
        )
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
            let content = try ContentGenerator().content(
                for: convertedSpec,
                templateUrl: templateUrl,
                useRegistry: useRegistry
            )
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
    func generateTuistPackage(
        at outputUrl: URL,
        targetDependenciesUrl: URL,
        modulesRelativePath: String,
        useRegistry: Bool
    ) async throws -> Path {
        let packageDependencies: Dependencies = try DTOLoader().loadDTO(url: packageDependenciesUrl)
        let targetDependencies: TargetDependencies = try DTOLoader().loadDTO(url: targetDependenciesUrl)

        let content = try ContentGenerator().content(
            packageDependencies: packageDependencies,
            targetDependencies: targetDependencies,
            templateUrl: templateUrl,
            modulesRelativePath: modulesRelativePath,
            useRegistry: useRegistry
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
