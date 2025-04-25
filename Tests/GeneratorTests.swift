//  GeneratorTests.swift

import XCTest
@testable import PackageGenerator

final class GeneratorTests: XCTestCase {

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

    let resourcesFolder = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources")

    lazy var packagesFolderUrl = resourcesFolder.appendingPathComponent("Packages")
    lazy var dependenciesFilename = "TestDependencies"
    lazy var versionRefs = "TestVersionRefs"
    lazy var templateUrl = resourcesFolder.appendingPathComponent("Package.stencil")

    private let fileManager = FileManager.default

    func test_SingleProduct() async throws {
        try await assertPackage(for: .singleProduct)
    }

    func test_RevisionProduct() async throws {
        try await assertPackage(for: .revisionProduct)
    }

    func test_BranchProduct() async throws {
        try await assertPackage(for: .branchProduct)
    }

    func test_MultipleProducts() async throws {
        try await assertPackage(for: .multipleProducts)
    }

    func test_customPlatforms() async throws {
        try await assertPackage(for: .customPlatforms)
    }

    func test_DependencyVersionOverride() async throws {
        try await assertPackage(for: .dependencyOverride)
    }

    func test_complexTargets() async throws {
        try await assertPackage(for: .complexTargets)
    }

    func test_executableProduct() async throws {
        try await assertPackage(for: .executableProduct)
    }

    func test_pluginProduct() async throws {
        try await assertPackage(for: .plugins)
    }

    func test_dependenciesAsBinaryTargets() async throws {
        try await assertConvertedPackage(for: .dependenciesAsBinaryTargets, exclusions: [])
    }

    func test_dependenciesAsBinaryTargetsWithExclusions() async throws {
        try await assertConvertedPackage(for: .dependenciesAsBinaryTargetsWithExclusions, exclusions: ["LocalDependencyA"])
    }

    private func assertPackage(for packageType: PackageType) async throws {
        for `extension` in ["json", "yml"] {
            let specUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent(packageType.rawValue)
                .appendingPathExtension(`extension`)

            let fixturePackageUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent("Package")
                .appendingPathExtension("swift")

            let dependenciesUrl = resourcesFolder
                .appendingPathComponent(dependenciesFilename)
                .appendingPathExtension("yml")

            let generator = Generator(
                templateUrl: templateUrl,
                dependenciesUrl: dependenciesUrl,
                dependencyFinder: MockDependencyFinder(),
                writer: MockWriter()
            )

            let sutPackageUrl = try await generator.generatePackage(
                at: fileManager.temporaryDirectory,
                filename: "Package.swift",
                specUrl: specUrl,
                dependencyTreatment: .standard
            )

            let sutPackageContent = try String(contentsOf: sutPackageUrl)
            let expectedPackageContent = try String(contentsOf: fixturePackageUrl)

            XCTAssertEqual(sutPackageContent, expectedPackageContent)
        }
    }

    private func assertConvertedPackage(for packageType: PackageType, exclusions: [String]) async throws {
        for `extension` in ["json", "yml"] {
            let specUrl = resourcesFolder
                .appendingPathComponent("Packages")
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent(packageType.rawValue)
                .appendingPathExtension(`extension`)

            let fixturePackageUrl = resourcesFolder
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

            let generator = Generator(
                templateUrl: templateUrl,
                dependenciesUrl: dependenciesUrl,
                dependencyFinder: MockDependencyFinder(),
                writer: MockWriter()
            )

            let sutPackageUrl = try await generator.generatePackage(
                at: fileManager.temporaryDirectory,
                filename: "tmp_\(UUID().uuidString)_Package.swift",
                specUrl: specUrl,
                dependencyTreatment: .binaryTargets(
                    relativeDependenciesPath: "../.xcframeworks",
                    versionRefsPath: versionRefsUrl.path(),
                    exclusions: exclusions
                )
            )

            let sutPackageContent = try String(contentsOf: sutPackageUrl)
            let expectedPackageContent = try String(contentsOf: fixturePackageUrl)

            XCTAssertEqual(sutPackageContent, expectedPackageContent)
        }
    }
}
