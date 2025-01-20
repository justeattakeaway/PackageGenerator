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

    private var fileManager: FileManager { .default }

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
        try await generator.generatePackage(dependencyTreatment: dependencyTreatment)
    }

    func validate() throws {
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
    }
}
