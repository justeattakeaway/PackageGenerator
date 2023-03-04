//  PackageGeneratorTests.swift

import XCTest
@testable import PackageGenerator

final class PackageGeneratorTests: XCTestCase {

    func test_packageGeneration() throws {
        let resourcesFolder = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")

        let packagesFolderUrl = resourcesFolder
            .appendingPathComponent("Packages")

        let dependenciesUrl = resourcesFolder
            .appendingPathComponent("TestRemoteDependencies.json")

        let templatePath = resourcesFolder
            .appendingPathComponent("Package.stencil")

        let packageName = "TestPackage"

        let packageUrl = packagesFolderUrl
            .appendingPathComponent(packageName)
            .appendingPathComponent("Package.swift")

        let specGenerator = SpecGenerator(dependenciesUrl: dependenciesUrl, packagesFolder: packagesFolderUrl)
        let spec = try specGenerator.makeSpec(for: packageName)
        let templater = Templater(templatePath: templatePath.absoluteString)
        let packageContent = try templater.renderTemplate(context: spec.makeContext())

        let expectedPackageContent = try String(contentsOf: packageUrl)

        XCTAssertEqual(packageContent, expectedPackageContent)
    }
}
