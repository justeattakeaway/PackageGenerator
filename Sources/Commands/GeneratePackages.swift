//  GeneratePackages.swift

import Foundation
import ArgumentParser

struct GeneratePackages: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate Package.swift files from a folder of packages.")
    
    @Option(name: .long, help: "Path to the folder containing the packages.")
    private var packagesFolderPath: String
    
    @Option(name: .long, help: "Path to the Stencil template.")
    private var templatePath: String
    
    @Option(name: .long, help: "Path to the RemoteDependencies.json file.")
    private var dependenciesPath: String
    
    func run() throws {
        let packagesFolderUrl = URL(fileURLWithPath: packagesFolderPath, isDirectory: true)
        let dependenciesUrl = URL(fileURLWithPath: dependenciesPath, isDirectory: false)
        let specGenerator = SpecGenerator(dependenciesUrl: dependenciesUrl, packagesFolder: packagesFolderUrl)
        let specs = try specGenerator.makeSpecs()
        
        let results: [String] = try specs.reduce(into: []) { partialResult, spec in
            let path = try generatePackage(for: spec)
            partialResult.append(path)
        }
        
        for result in results {
            print("✅ File successfully saved at \(result).")
        }
    }
    
    private func generatePackage(for spec: Spec) throws -> Path {
        let templater = Templater(templatePath: templatePath)
        let content = try templater.renderTemplate(context: spec.makeContext())
        let packagesFolderPath = URL(fileURLWithPath: packagesFolderPath, isDirectory: true)
            .appendingPathComponent(spec.name)
            .path
        return try Writer().writePackageFile(content: content, to: packagesFolderPath)
    }
}
