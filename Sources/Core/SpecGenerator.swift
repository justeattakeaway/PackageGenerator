//  SpecGenerator.swift

import Foundation
import Yams

/// Class to generate Specs models that can be used to ultimately generate `Package.swift` files.
final class SpecGenerator {
    
    enum GeneratorError: Error {
        case invalidFormat(String)
    }
    
    /// Generate a Spec model for a given package.
    ///
    /// - Parameters:
    ///   - packagesFolder: Path  to the package spec.
    ///   - dependenciesUrl: Path  to the dependencies file.
    /// - Returns: A Spec model.
    func makeSpec(specUrl: URL, dependenciesUrl: URL) throws -> Spec {
        let spec: Spec = try DTOLoader().loadDto(url: specUrl)
        let dependencies: Dependencies = try DTOLoader().loadDto(url: dependenciesUrl)

        let mappedDependencies: [Spec.RemoteDependency] = spec.remoteDependencies
            .compactMap { remoteDependency -> Spec.RemoteDependency? in
                guard let dependency = dependencies.dependencies.first(where: {
                    $0.name == remoteDependency.name
                }) else {
                    return nil
                }
                return Spec.RemoteDependency(
                    name: dependency.name,
                    url: remoteDependency.url ?? dependency.url,
                    ref: remoteDependency.ref ?? dependency.ref
                )
            }
        
        return Spec(
            name: spec.name,
            platforms: spec.platforms,
            localDependencies: spec.localDependencies,
            remoteDependencies: mappedDependencies,
            products: spec.products,
            targets: spec.targets,
            localBinaryTargets: spec.localBinaryTargets,
            remoteBinaryTargets: spec.remoteBinaryTargets,
            swiftToolsVersion: spec.swiftToolsVersion,
            swiftLanguageVersions: spec.swiftLanguageVersions
        )
    }
}
