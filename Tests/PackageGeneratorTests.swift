//  PackageGeneratorTests.swift

import XCTest
@testable import PackageGenerator

final class PackageGeneratorTests: XCTestCase {

    enum PackageType: String {
        case revisionProduct = "RevisionProduct"
        case branchProduct = "BranchProduct"
        case singleProduct = "SingleProduct"
        case multipleProducts = "MultipleProducts"
        case customPlatforms = "CustomPlatforms"
        case dependencyOverride = "DependencyOverride"
        case complexTargets = "ComplexTargets"
        case executableProduct = "ExecutableProduct"
        case plugins = "PluginProduct"
        case dependenciesAsBinaryTargets = "DependenciesAsBinaryTargets"
        case dependenciesAsBinaryTargetsWithExclusions = "DependenciesAsBinaryTargetsWithExclusions"
    }

    let resourcesFolder = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources")

    lazy var packagesFolderUrl = resourcesFolder.appendingPathComponent("Packages")
    lazy var dependenciesFilename = "TestDependencies"
    lazy var versionRefs = "TestVersionRefs"
    lazy var templatePath = resourcesFolder.appendingPathComponent("Package.stencil")

    func test_SingleProduct() throws {
        try assertPackage(for: .singleProduct)
    }

    func test_RevisionProduct() throws {
        try assertPackage(for: .revisionProduct)
    }

    func test_BranchProduct() throws {
        try assertPackage(for: .branchProduct)
    }

    func test_MultipleProducts() throws {
        try assertPackage(for: .multipleProducts)
    }

    func test_customPlatforms() throws {
        try assertPackage(for: .customPlatforms)
    }

    func test_DependencyVersionOverride() throws {
        try assertPackage(for: .dependencyOverride)
    }

    func test_complexTargets() throws {
        try assertPackage(for: .complexTargets)
    }

    func test_executableProduct() throws {
        try assertPackage(for: .executableProduct)
    }

    func test_pluginProduct() throws {
        try assertPackage(for: .plugins)
    }

    func test_dependenciesAsBinaryTargets() async throws {
        try await assertConvertedPackage(for: .dependenciesAsBinaryTargets, exclusions: [])
    }

    func test_dependenciesAsBinaryTargetsWithExclusions() async throws {
        try await assertConvertedPackage(for: .dependenciesAsBinaryTargetsWithExclusions, exclusions: ["LocalDependencyA"])
    }

    private func assertPackage(for packageType: PackageType) throws {
        for `extension` in ["json", "yml"] {
            let specUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent(packageType.rawValue)
                .appendingPathExtension(`extension`)

            let packageUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent("Package")
                .appendingPathExtension("swift")

            let dependenciesUrl = resourcesFolder
                .appendingPathComponent(dependenciesFilename)
                .appendingPathExtension("yml")

            let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: dependenciesUrl)
            let templater = Templater(templateUrl: templatePath)
            let packageContent = try templater.renderTemplate(context: spec.makeContext())

            let expectedPackageContent = try String(contentsOf: packageUrl)

            XCTAssertEqual(packageContent, expectedPackageContent)
        }
    }

    private func assertConvertedPackage(for packageType: PackageType, exclusions: [String]) async throws {
        for `extension` in ["json", "yml"] {
            let specUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent(packageType.rawValue)
                .appendingPathExtension(`extension`)

            let packageUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent("Package")
                .appendingPathExtension("swift")

            let dependenciesUrl = resourcesFolder
                .appendingPathComponent(dependenciesFilename)
                .appendingPathExtension("yml")

            let versionRefsUrl = resourcesFolder
                .appendingPathComponent(versionRefs)
                .appendingPathExtension("json")

            let spec = try SpecGenerator().makeSpec(specUrl: specUrl, dependenciesUrl: dependenciesUrl)
            let templater = Templater(templateUrl: templatePath)
            let packageContent = try templater.renderTemplate(context: spec.makeContext())

            let tmpFilename = "tmp_\(UUID().uuidString)_Package.swift"
            let tmpPackageUrl = try saveFileToTempDirectory(filename: tmpFilename, content: packageContent)

            let packageConvertor = PackageConvertor()
            let convertedSpec = try await packageConvertor.convertDependenciesToBinaryTargets(
                dependencyFinder: MockDependencyFinder(),
                spec: spec,
                packageFilePath: tmpPackageUrl.path(),
                relativeDependenciesPath: "../.xcframeworks",
                versionRefsPath: versionRefsUrl.path(),
                exclusions: exclusions
            )

            let convertedPackageContent = try templater.renderTemplate(context: convertedSpec.makeContext())

            let expectedPackageContent = try String(contentsOf: packageUrl)

            XCTAssertEqual(convertedPackageContent, expectedPackageContent)
        }
    }

    private func saveFileToTempDirectory(filename: String, content: Content) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory
            .appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
