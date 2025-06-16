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
    ///   - useRegistry: Whether to use a Swift Registry.
    /// - Returns: A Spec model.
    func makeSpec(specUrl: URL, dependenciesUrl: URL, useRegistry: Bool) throws -> Spec {
        let spec: Spec = try DTOLoader().loadDTO(url: specUrl)
        let dependencies: Dependencies = try DTOLoader().loadDTO(url: dependenciesUrl)

        // Enriching the spec with data from the dependencies file
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
                    identifier: dependency.identifier,
                    ref: remoteDependency.ref ?? dependency.ref
                )
            }

        let mappedTargets = spec.targets
            .compactMap { target -> Spec.Target in
                let mappedDependencies = target.dependencies
                    .compactMap { dependency -> Spec.TargetDependency in
                        let package = {
                            if useRegistry {
                                dependencies.dependencies.first(where: {
                                    $0.name == dependency.dependency
                                })?.identifier ?? dependency.package
                            } else {
                                dependency.package
                            }
                        }()
                        return Spec.TargetDependency(
                            name: dependency.name,
                            package: package,
                            dependency: dependency.dependency,
                            isTarget: dependency.isTarget
                        )
                    }

                return Spec.Target(
                    targetType: target.targetType,
                    name: target.name,
                    dependencies: mappedDependencies,
                    sourcesPath: target.sourcesPath,
                    resourcesPath: target.resourcesPath,
                    exclude: target.exclude,
                    swiftSettings: target.swiftSettings,
                    cSettings: target.cSettings,
                    cxxSettings: target.cxxSettings,
                    linkerSettings: target.linkerSettings,
                    publicHeadersPath: target.publicHeadersPath,
                    plugins: target.plugins
                )
            }

        return Spec(
            name: spec.name,
            platforms: spec.platforms,
            localDependencies: spec.localDependencies,
            remoteDependencies: mappedDependencies,
            products: spec.products,
            targets: mappedTargets,
            localBinaryTargets: spec.localBinaryTargets,
            remoteBinaryTargets: spec.remoteBinaryTargets,
            swiftToolsVersion: spec.swiftToolsVersion,
            swiftLanguageVersions: spec.swiftLanguageVersions
        )
    }
}
