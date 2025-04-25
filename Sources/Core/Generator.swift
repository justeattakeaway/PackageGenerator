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
    func generatePackage(at folder: URL, filename: String, specUrl: URL, dependencyTreatment: DependencyTreatment) async throws -> Path {
        let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: dependenciesUrl)
        let content = try ContentGenerator().content(for: spec, templateUrl: templateUrl)
        let path = try writer.write(
            content: content,
            folder: folder,
            filename: filename
        )
        print("✅ File successfully saved at \(path).")

        switch dependencyTreatment {
        case .standard:
            return path
        case .binaryTargets(let relativeDependenciesPath, let versionRefsPath, let exclusions):
            print("✅ Converting \(path) to use dependencies as binary targets.")
            let packageConvertor = PackageConvertor()
            let convertedSpec = try await packageConvertor.convertDependenciesToBinaryTargets(
                dependencyFinder: dependencyFinder,
                spec: spec,
                packageFileUrl: path,
                relativeDependenciesPath: relativeDependenciesPath,
                versionRefsPath: versionRefsPath,
                exclusions: exclusions
            )
            let content = try ContentGenerator().content(for: convertedSpec, templateUrl: templateUrl)
            let path = try writer.write(
                content: content,
                folder: folder,
                filename: filename
            )
            print("✅ File successfully updated at \(path).")
            return path
        }
    }
}
