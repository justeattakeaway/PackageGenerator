//  GenerateTuistPackage.swift

import ArgumentParser
import Foundation

struct GenerateTuistPackage: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a Tuist/Package.swift file from a list of package dependencies.")

    @Option(name: .long, help: "Path to the output folder (default to 'Tuist').")
    var output: String = "Tuist"

    @Option(name: .long, help: "Path to a package dependencies file (supported formats: json, yaml).")
    var packageDependencies: String

    @Option(name: .long, help: "Path to a target dependencies file (supported formats: json, yaml).")
    var targetDependencies: String

    @Option(name: .long, help: "Path to a template file (supported formats: stencil).")
    var template: String

    @Flag(name: .long, help: "Whether to use a Swift Registry.")
    var useSwiftRegistry: Bool = false

    @Option(name: .long, help: "Path to a folder containing the modules in individual folders (default to 'Modules'). Relative to the root of the repository. Required if targetDependencies contains local dependencies.")
    var modulesRelativePath: String = "Modules"

    private var fileManager: FileManager { .default }

    func run() async throws {
        let generator = Generator(
            templateUrl: URL(filePath: template, directoryHint: .notDirectory),
            packageDependenciesUrl: URL(filePath: packageDependencies, directoryHint: .notDirectory),
            dependencyFinder: DependencyFinder(fileManager: fileManager),
            writer: Writer(),
            fileManager: fileManager
        )
        let outputPath = URL(filePath: output, directoryHint: .notDirectory)
        let targetDependenciesUrl = URL(filePath: targetDependencies, directoryHint: .notDirectory)

        try await generator.generateTuistPackage(
            at: outputPath,
            targetDependenciesUrl: targetDependenciesUrl,
            modulesRelativePath: modulesRelativePath,
            useRegistry: useSwiftRegistry
        )
    }

    func validate() throws {
        if fileManager.fileExists(atPath: packageDependencies) == false {
            throw ValidationError("The file \(packageDependencies) does not exist.")
        }
        if fileManager.fileExists(atPath: targetDependencies) == false {
            throw ValidationError("The file \(targetDependencies) does not exist.")
        }
        if fileManager.fileExists(atPath: modulesRelativePath) == false {
            throw ValidationError("The folder \(modulesRelativePath) does not exist.")
        }
    }
}
