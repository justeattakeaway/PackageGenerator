//  GeneratePackage.swift

import ArgumentParser
import Foundation

struct GeneratePackage: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a Package.swift file from a spec.")

    @Option(name: .long, help: "Path to a package spec file (supported formats: json, yaml).")
    var spec: String

    @Option(name: .long, help: "Path to a package dependencies file (supported formats: json, yaml).")
    var packageDependencies: String

    @Option(name: .long, help: "Path to a template file (supported formats: stencil).")
    var template: String

    @Flag(name: .long, help: "Whether to use a Swift Registry.")
    var useSwiftRegistry: Bool = false

    @OptionGroup()
    var cachingFlags: CachingFlags

    @Option(name: .long, help: "Allowed shared local dependencies. Can be specified multiple times.")
    var allowedSharedLocalDependencies: [String] = []
    
    private var fileManager: FileManager { .default }

    func run() async throws {
        let generator = Generator(
            templateUrl: URL(filePath: template, directoryHint: .notDirectory),
            packageDependenciesUrl: URL(filePath: packageDependencies, directoryHint: .notDirectory),
            dependencyFinder: DependencyFinder(fileManager: fileManager),
            writer: Writer(),
            fileManager: fileManager
        )
        let dependencyTreatment: Generator.DependencyTreatment = try {
            if cachingFlags.dependenciesAsBinaryTargets {
                guard let relativeDependenciesPath = cachingFlags.relativeDependenciesPath else {
                    throw ValidationError("--dependencies-as-binary-targets is set but --relative-dependencies-path is not specified")
                }
                guard let versionRefsPath = cachingFlags.versionRefsPath else {
                    throw ValidationError("--dependencies-as-binary-targets is set but --version-refs-path is not specified")
                }
                return .binaryTargets(
                    relativeDependenciesPath: relativeDependenciesPath,
                    versionRefsPath: versionRefsPath,
                    exclusions: cachingFlags.exclusions
                )
            }
            return .standard
        }()
        let specUrl = URL(filePath: spec, directoryHint: .notDirectory)
        try await generator.generatePackage(
            at: specUrl.deletingLastPathComponent(),
            filename: Constants.packageFile,
            specUrl: specUrl,
            dependencyTreatment: dependencyTreatment,
            useRegistry: useSwiftRegistry
        )
    }

    func validate() throws {
        if fileManager.fileExists(atPath: packageDependencies) == false {
            throw ValidationError("The file \(packageDependencies) does not exist.")
        }
        if cachingFlags.dependenciesAsBinaryTargets {
            if cachingFlags.relativeDependenciesPath == nil {
                throw ValidationError("--dependencies-as-binary-targets is set but --relative-dependencies-path is not specified")
            }
            guard let versionRefsPath = cachingFlags.versionRefsPath else {
                throw ValidationError("--dependencies-as-binary-targets is set but --version-refs-path is not specified")
            }
            if fileManager.fileExists(atPath: versionRefsPath) == false {
                throw ValidationError("The file \(versionRefsPath) does not exist.")
            }
        }
        if !cachingFlags.dependenciesAsBinaryTargets {
            if cachingFlags.relativeDependenciesPath != nil {
                throw ValidationError("--relative-dependencies-path specified but --dependencies-as-binary-targets is unset")
            }
            if cachingFlags.versionRefsPath != nil {
                throw ValidationError("--version-refs-path specified but --dependencies-as-binary-targets is unset")
            }
        }
        if !allowedSharedLocalDependencies.isEmpty {
            let specUrl = URL(filePath: spec, directoryHint: .notDirectory)
            let packageDependenciesUrl = URL(filePath: packageDependencies, directoryHint: .notDirectory)
            let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: packageDependenciesUrl, useRegistry: useSwiftRegistry)
            let validator = DependenciesValidator(allowedSharedLocalDependencies: allowedSharedLocalDependencies)
            try validator.validateSharedLocalDependencies(spec)
        }
    }
}
