//  DependenciesValidatorTests.swift

import XCTest
@testable import PackageGenerator

final class DependenciesValidatorTests: XCTestCase {
    
    func test_allDependenciesAllowed_doesNotThrow() throws {
        let spec = Spec(
            name: "ModuleA",
            platforms: nil,
            localDependencies: [
                Spec.LocalDependency(name: "SharedUI", path: ""),
                Spec.LocalDependency(name: "SharedNetworking", path: "")
            ],
            remoteDependencies: [],
            products: [],
            targets: [],
            localBinaryTargets: [],
            remoteBinaryTargets: [],
            swiftToolsVersion: nil,
            swiftLanguageVersions: []
        )
        let validator = DependenciesValidator(allowedSharedLocalDependencies: ["SharedUI", "SharedNetworking"])
        XCTAssertNoThrow(try validator.validateSharedLocalDependencies(spec))
    }
    
    func test_disallowedDependency_throwsError() throws {
        let spec = Spec(
            name: "ModuleA",
            platforms: nil,
            localDependencies: [
                Spec.LocalDependency(name: "SharedUI", path: ""),
                Spec.LocalDependency(name: "NotAllowedModule", path: "")
            ],
            remoteDependencies: [],
            products: [],
            targets: [],
            localBinaryTargets: [],
            remoteBinaryTargets: [],
            swiftToolsVersion: nil,
            swiftLanguageVersions: []
        )
        let validator = DependenciesValidator(allowedSharedLocalDependencies: ["SharedUI"])
        do {
            try validator.validateSharedLocalDependencies(spec)
            XCTFail("Expected error was not thrown")
        } catch let error as DependenciesValidatorError {
            switch error {
            case let .disallowedSharedLocalDependency(moduleName, localDependencyName, allowedSharedLocalDependencies):
                XCTAssertEqual(moduleName, "ModuleA")
                XCTAssertEqual(localDependencyName, "NotAllowedModule")
                XCTAssertEqual(allowedSharedLocalDependencies, ["SharedUI"])
            }
        }
    }
    
    func test_noLocalDependencies_doesNotThrow() throws {
        let spec = Spec(
            name: "ModuleC",
            platforms: nil,
            localDependencies: [],
            remoteDependencies: [],
            products: [],
            targets: [],
            localBinaryTargets: [],
            remoteBinaryTargets: [],
            swiftToolsVersion: nil,
            swiftLanguageVersions: []
        )
        let validator = DependenciesValidator(allowedSharedLocalDependencies: ["SharedUI"])
        XCTAssertNoThrow(try validator.validateSharedLocalDependencies(spec))
    }
}
