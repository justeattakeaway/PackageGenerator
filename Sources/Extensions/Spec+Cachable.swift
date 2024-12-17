//  Spec+Cachable.swift

import Foundation

extension Spec {

    func cachableSpec(additionalLocalBinaryTargets: [LocalBinaryTarget], exclusions: [String]) -> Spec {
        let products = products.map { product in
            if product.productType == .library {
                return Spec.Product.init(
                    name: product.name,
                    productType: product.productType,
                    libraryType: .dynamic,
                    targets: product.targets
                )
            }
            return product
        }

        let localDependencies = localDependencies.filter { exclusions.contains($0.name) }
        let remoteDependencies = remoteDependencies.filter { exclusions.contains($0.name) }

        let targets = targets.map { target in
            let dependencies = target.dependencies.filter {
                if exclusions.contains($0.name) { return true }
                if let isTarget = $0.isTarget { return isTarget }
                return false
            }
            return Spec.Target(
                targetType: target.targetType,
                name: target.name,
                dependencies: dependencies,
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
            name: name,
            platforms: platforms,
            localDependencies: localDependencies,
            remoteDependencies: remoteDependencies,
            products: products,
            targets: targets,
            localBinaryTargets: (localBinaryTargets ?? []) + additionalLocalBinaryTargets,
            remoteBinaryTargets: remoteBinaryTargets,
            swiftToolsVersion: swiftToolsVersion,
            swiftLanguageVersions: swiftLanguageVersions
        )
    }
}
