//  GeneratePackage.swift

import Foundation
import ArgumentParser

struct GeneratePackage: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a Package.swift file from a JSON manifest.")
    
    @Option(name: .long, help: "Path to the folder containing the package.")
    private var path: String
    
    @Option(name: .long, help: "Path to the Stencil template.")
    private var templatePath: String

    @Option(name: .long, help: "Path to the RemoteDependencies.json file.")
    private var dependenciesPath: String
    
    func run() throws {
        let packageFolderUrl = URL(fileURLWithPath: path, isDirectory: true)
        let packageFolderName = packageFolderUrl.lastPathComponent
        let dependenciesUrl = URL(fileURLWithPath: dependenciesPath, isDirectory: false)
        let specGenerator = SpecGenerator(dependenciesUrl: dependenciesUrl, packagesFolder: packageFolderUrl)
        let specUrl = packageFolderUrl.appendingPathComponent("\(packageFolderName).json")
        let spec = try specGenerator.makeSpec(for: packageFolderName, specUrl: specUrl)
        let path = try generatePackage(for: spec)
        print("✅ File successfully saved at \(path).")
    }

    private func generatePackage(for spec: Spec) throws -> Path {
        let templater = Templater(templatePath: templatePath)
        let content = try templater.renderTemplate(context: spec.makeContext())
        return try Writer().writePackageFile(content: content, to: path)
    }
}
