//  GeneratorTests.swift

import XCTest
@testable import PackageGenerator

final class GeneratorTests: XCTestCase {

    enum SupportedFormat: String, CaseIterable {
        case json
        case yml
    }

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
        case registryDisabled = "RegistryDisabled"
        case registryEnabled = "RegistryEnabled"
        case dependenciesAsBinaryTargets = "DependenciesAsBinaryTargets"
        case dependenciesAsBinaryTargetsWithExclusions = "DependenciesAsBinaryTargetsWithExclusions"
        case tuist = "Tuist"
    }

    let resourcesFolder = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Resources")

    lazy var fixturesFolderUrl = resourcesFolder.appendingPathComponent("Fixtures")
    lazy var packagesFolderUrl = resourcesFolder.appendingPathComponent("Packages")
    lazy var templatesFolderUrl = resourcesFolder.appendingPathComponent("Templates")

    lazy var packageDependenciesFilename = "TestPackageDependencies"
    lazy var targetDependenciesFilename = "TestTargetDependencies"
    lazy var versionRefs = "TestVersionRefs"
    lazy var templateUrl = templatesFolderUrl.appendingPathComponent("Package.stencil")
    lazy var tuistTemplateUrl = templatesFolderUrl.appendingPathComponent("TuistPackage.stencil")

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

    func test_registry_useRegistryFalse() async throws {
        try await assertPackage(for: .registryDisabled, useRegistry: false)
    }

    func test_registry_useRegistryTrue() async throws {
        try await assertPackage(for: .registryEnabled, useRegistry: true)
    }

    func test_dependenciesAsBinaryTargets() async throws {
        try await assertConvertedPackage(for: .dependenciesAsBinaryTargets, exclusions: [])
    }

    func test_dependenciesAsBinaryTargetsWithExclusions() async throws {
        try await assertConvertedPackage(for: .dependenciesAsBinaryTargetsWithExclusions, exclusions: ["LocalDependencyA"])
    }

    func test_tuist() async throws {
        try await assertTuistPackage(for: .tuist)
    }

    private func assertPackage(for packageType: PackageType, useRegistry: Bool = false) async throws {
        for format in SupportedFormat.allCases {
            let specUrl = packagesFolderUrl
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent(packageType.rawValue)
                .appendingPathExtension(format.rawValue)

            let packageUrl = packagesFolderUrl
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent("Package")
                .appendingPathExtension("swift")

            let packageDependenciesUrl = fixturesFolderUrl
                .appendingPathComponent(packageDependenciesFilename)
                .appendingPathExtension("yml")

            let generator = Generator(
                templateUrl: templateUrl,
                packageDependenciesUrl: packageDependenciesUrl,
                dependencyFinder: MockDependencyFinder(),
                writer: MockWriter(),
                fileManager: fileManager
            )

            let sutPackageUrl = try await generator.generatePackage(
                at: fileManager.temporaryDirectory,
                filename: "Package.swift",
                specUrl: specUrl,
                dependencyTreatment: .standard,
                useRegistry: useRegistry
            )

            let sutPackageContent = try String(contentsOf: sutPackageUrl)
            let expectedPackageContent = try String(contentsOf: packageUrl)

            XCTAssertEqual(sutPackageContent, expectedPackageContent)
        }
    }

    private func assertConvertedPackage(for packageType: PackageType, exclusions: [String]) async throws {
        for format in SupportedFormat.allCases {
            let specUrl = packagesFolderUrl
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent(packageType.rawValue)
                .appendingPathExtension(format.rawValue)

            let packageUrl = packagesFolderUrl
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent("Package")
                .appendingPathExtension("swift")

            let packageDependenciesUrl = fixturesFolderUrl
                .appendingPathComponent(packageDependenciesFilename)
                .appendingPathExtension("yml")

            let versionRefsUrl = fixturesFolderUrl
                .appendingPathComponent(versionRefs)
                .appendingPathExtension("json")

            let generator = Generator(
                templateUrl: templateUrl,
                packageDependenciesUrl: packageDependenciesUrl,
                dependencyFinder: MockDependencyFinder(),
                writer: MockWriter(),
                fileManager: fileManager
            )

            let sutPackageUrl = try await generator.generatePackage(
                at: fileManager.temporaryDirectory,
                filename: "tmp_\(UUID().uuidString)_Package.swift",
                specUrl: specUrl,
                dependencyTreatment: .binaryTargets(
                    relativeDependenciesPath: "../.xcframeworks",
                    versionRefsPath: versionRefsUrl.path(),
                    exclusions: exclusions
                ),
                useRegistry: false
            )

            let sutPackageContent = try String(contentsOf: sutPackageUrl)
            let expectedPackageContent = try String(contentsOf: packageUrl)

            XCTAssertEqual(sutPackageContent, expectedPackageContent)
        }
    }

    private func assertTuistPackage(for packageType: PackageType) async throws {
        for format in SupportedFormat.allCases {
            let fixturePackageUrl = packagesFolderUrl
                .appendingPathComponent(packageType.rawValue)
                .appendingPathComponent("Package")
                .appendingPathExtension("swift")

            let packageDependenciesUrl = fixturesFolderUrl
                .appendingPathComponent(packageDependenciesFilename)
                .appendingPathExtension(format.rawValue)

            let targetDependenciesUrl = fixturesFolderUrl
                .appendingPathComponent(targetDependenciesFilename)
                .appendingPathExtension(format.rawValue)

            let generator = Generator(
                templateUrl: tuistTemplateUrl,
                packageDependenciesUrl: packageDependenciesUrl,
                dependencyFinder: MockDependencyFinder(),
                writer: MockWriter(),
                fileManager: fileManager
            )

            let sutPackageUrl = try await generator.generateTuistPackage(
                at: fileManager.temporaryDirectory,
                targetDependenciesUrl: targetDependenciesUrl,
                modulesRelativePath: "Modules",
                useRegistry: false
            )

            let sutPackageContent = try String(contentsOf: sutPackageUrl)
            let expectedPackageContent = try String(contentsOf: fixturePackageUrl)

            XCTAssertEqual(sutPackageContent, expectedPackageContent)
        }
    }
}
