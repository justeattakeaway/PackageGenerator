//  GeneratePackage.swift

import Foundation
import ArgumentParser

struct GeneratePackage: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate the Package.swift file for a given module.")
    
    @Option(name: .long, help: "Path to the folder containing the modules.")
    private var modulesFolder: String
    
    @Option(name: .long, help: "Path to the Stencil template.")
    private var templatePath: String

    @Option(name: .long, help: "Path to the RemoteDependencies.json file.")
    private var dependenciesPath: String

    @Option(name: .long, help: "The name of the module to generate the Package.swift for.")
    private var moduleName: String
    
    func run() throws {
        let modulesFolderUrl = URL(fileURLWithPath: modulesFolder, isDirectory: true)
        let dependenciesUrl = URL(fileURLWithPath: dependenciesPath, isDirectory: false)
        let specGenerator = SpecGenerator(dependenciesUrl: dependenciesUrl, modulesFolder: modulesFolderUrl)
        let spec = try specGenerator.makeSpec(for: moduleName)
        let path = try generatePackage(for: spec)
        print("File successfully saved at \(path).")
    }

    private func generatePackage(for spec: Spec) throws -> Path {
        let templater = Templater(templatePath: templatePath)
        let content = try templater.renderTemplate(context: spec.makeContext())
        return try Writer().writePackageFile(content: content, to: modulesFolder, moduleName: spec.name)
    }
}
