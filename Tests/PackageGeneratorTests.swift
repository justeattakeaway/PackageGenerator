//  PackageGeneratorTests.swift

import XCTest
@testable import PackageGenerator

final class PackageGeneratorTests: XCTestCase {

    func test_packageGeneration() throws {
        let resourcesFolder = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")

        let modulesFolderUrl = resourcesFolder
            .appendingPathComponent("Modules")

        let dependenciesUrl = resourcesFolder
            .appendingPathComponent("TestRemoteDependencies.json")

        let templatePath = resourcesFolder
            .appendingPathComponent("Package.stencil")

        let moduleName = "TestModule"

        let packageUrl = modulesFolderUrl
            .appendingPathComponent(moduleName)
            .appendingPathComponent("Package.swift")

        let specGenerator = SpecGenerator(dependenciesUrl: dependenciesUrl, modulesFolder: modulesFolderUrl)
        let spec = try specGenerator.makeSpec(for: moduleName)
        let templater = Templater(templatePath: templatePath.absoluteString)
        let packageContent = try templater.renderTemplate(context: spec.makeContext())

        let expectedPackageContent = try String(contentsOf: packageUrl)

        XCTAssertEqual(packageContent, expectedPackageContent)
    }
}
