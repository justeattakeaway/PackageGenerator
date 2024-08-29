//  GeneratePackage.swift

import ArgumentParser
import Foundation

struct GeneratePackage: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a Package.swift file from a spec.")

    @Option(name: .long, help: "Path to a package spec file (supported formats: json, yaml)")
    private var spec: String

    @Option(name: .long, help: "Path to s dependencies file (supported formats: json, yaml)")
    private var dependencies: String

    @Option(name: .long, help: "Path to a template file (supported formats: stencil)")
    private var template: String

    func run() throws {
        let content = try generatePackageContent()
        let path = try write(content: content)
        print("✅ File successfully saved at \(path).")
    }

    private func generatePackageContent() throws -> Content {
        let specUrl = URL(fileURLWithPath: spec, isDirectory: false)
        let dependenciesUrl = URL(fileURLWithPath: dependencies, isDirectory: false)
        let specGenerator = SpecGenerator(specUrl: specUrl, dependenciesUrl: dependenciesUrl)
        let spec = try specGenerator.makeSpec()
        let templater = Templater(templatePath: template)
        return try templater.renderTemplate(context: spec.makeContext())
    }

    private func write(content: Content) throws -> String {
        let specUrl = URL(fileURLWithPath: spec, isDirectory: false)
        let packageFolder = specUrl.deletingLastPathComponent()
        return try Writer().writePackageFile(content: content, to: packageFolder)
    }
}
