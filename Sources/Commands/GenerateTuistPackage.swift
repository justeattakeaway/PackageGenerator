//  GenerateTuistPackage.swift

import ArgumentParser
import Foundation

struct GenerateTuistPackage: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a Tuist/Package.swift file from a list of package dependencies.")

    @Option(name: .long, help: "Path to the output folder (default to 'Tuist').")
    var output: String = "Tuist"

    @Option(name: .long, help: "Path to a dependencies file (supported formats: json, yaml).")
    var dependencies: String

    @Option(name: .long, help: "Path to a folder containing the modules in individual folders (default to 'Modules').")
    var modulesFolder: String = "Modules"

    @Option(name: .long, help: "Path to a template file (supported formats: stencil).")
    var template: String

    private var fileManager: FileManager { .default }

    func run() async throws {
        let generator = Generator(
            templateUrl: URL(filePath: template, directoryHint: .notDirectory),
            dependenciesUrl: URL(filePath: dependencies, directoryHint: .notDirectory),
            dependencyFinder: DependencyFinder(fileManager: fileManager),
            writer: Writer()
        )
        let outputPath = URL(filePath: output, directoryHint: .notDirectory)
        try await generator.generateTuistPackage(
            at: outputPath,
            modulesPath: modulesFolder,
            localModuleLister: LocalModuleLister()
        )
    }

    func validate() throws {
        if fileManager.fileExists(atPath: dependencies) == false {
            throw ValidationError("The file \(dependencies) does not exist.")
        }
        if fileManager.fileExists(atPath: modulesFolder) == false {
            throw ValidationError("The folder \(modulesFolder) does not exist.")
        }
    }
}
