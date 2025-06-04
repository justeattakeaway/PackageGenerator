//  DependenciesValidatorError.swift

import Foundation
import ArgumentParser

struct DependenciesValidator {
    
    private let allowedSharedLocalDependencies: Set<String>
    
    init(allowedSharedLocalDependencies: [String]) {
        self.allowedSharedLocalDependencies = Set(allowedSharedLocalDependencies)
    }
    
    /// Validates that all local dependencies of the given spec are allowed shared local dependencies.
    ///
    /// - Parameter spec: The `Spec` instance whose local dependencies will be validated.
    /// - Throws: `DependenciesValidatorError.disallowedSharedLocalDependency` if a local dependency is not in the allowed list.
    func validateSharedLocalDependencies(_ spec: Spec) throws {
        for dependency in spec.localDependencies {
            guard allowedSharedLocalDependencies.contains(dependency.name) else {
                throw DependenciesValidatorError.disallowedSharedLocalDependency(
                    moduleName: spec.name,
                    localDependencyName: dependency.name,
                    allowedSharedLocalDependencies: allowedSharedLocalDependencies
                )
            }
        }
    }
}

// MARK: - Error Definitions

enum DependenciesValidatorError: LocalizedError {
    
    case disallowedSharedLocalDependency(
        moduleName: String,
        localDependencyName: String,
        allowedSharedLocalDependencies: Set<String>
    )
    
    var errorDescription: String? {
        switch self {
        case let .disallowedSharedLocalDependency(moduleName, localDependencyName, allowedSharedLocalDependencies):
            let allowedSharedLocalDependenciesList = allowedSharedLocalDependencies.joined(separator: ", ")
            return "'\(moduleName)' cannot depend on '\(localDependencyName)'. Allowed shared local dependencies are: \(allowedSharedLocalDependenciesList)."
        }
    }
}
