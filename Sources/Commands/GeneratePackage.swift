//  GeneratePackage.swift

import ArgumentParser
import Foundation

struct GeneratePackage: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a Package.swift file from a spec.")

    @Option(name: .long, help: "Path to a package spec file (supported formats: json, yaml).")
    var spec: String

    @Option(name: .long, help: "Path to s dependencies file (supported formats: json, yaml).")
    var dependencies: String

    @Option(name: .long, help: "Path to a template file (supported formats: stencil).")
    var template: String

    @OptionGroup()
    var cachingFlags: CachingFlags

    func run() async throws {
        let generator = Generator(
            specUrl: URL(filePath: spec, directoryHint: .notDirectory),
            templateUrl: URL(filePath: template, directoryHint: .notDirectory),
            dependenciesUrl: URL(fileURLWithPath: dependencies, isDirectory: false),
            fileManager: .default
        )
        let dependencyTreatment: Generator.DependencyTreatment = try {
            if cachingFlags.dependenciesAsBinaryTargets {
                guard let relativeDependenciesPath = cachingFlags.relativeDependenciesPath else {
                    throw ValidationError("--dependencies-as-binary-targets is set but --relative-dependencies-path is not specified")
                }
                return .binaryTargets(
                    relativeDependenciesPath: relativeDependenciesPath,
                    requiredHashingPaths: cachingFlags.requiredHashingPaths,
                    optionalHashingPaths: cachingFlags.optionalHashingPaths,
                    exclusions: cachingFlags.exclusions
                )
            }
            return .standard
        }()
        try await generator.generatePackage(dependencyTreatment: dependencyTreatment)
    }

    func validate() throws {
        if cachingFlags.dependenciesAsBinaryTargets {
            if cachingFlags.relativeDependenciesPath == nil {
                throw ValidationError("--dependencies-as-binary-targets is set but --relative-dependencies-path is not specified")
            }
            if cachingFlags.requiredHashingPaths.isEmpty {
                throw ValidationError("--dependencies-as-binary-targets is set but --required-hashing-paths is not specified")
            }
        }
        if !cachingFlags.dependenciesAsBinaryTargets {
            if cachingFlags.relativeDependenciesPath != nil {
                throw ValidationError("--relative-dependencies-path specified but --dependencies-as-binary-targets is unset")
            }
            if !cachingFlags.requiredHashingPaths.isEmpty {
                throw ValidationError("--required-hashing-paths specified but --dependencies-as-binary-targets is unset")
            }
        }
    }
}
