//  SpecGenerator.swift

import Foundation
import Yams

/// Class to generate Specs models that can be used to ultimately generate `Package.swift` files.
final class SpecGenerator {

    enum GeneratorError: Error {
        case invalidFormat(String)
    }

    let specUrl: URL
    let dependenciesUrl: URL

    /// The default initializer.
    ///
    /// - Parameters:
    ///   - packagesFolder: Path  to the package spec.
    ///   - dependenciesUrl: Path  to the dependencies file.
    init(specUrl: URL, dependenciesUrl: URL) {
        self.specUrl = specUrl
        self.dependenciesUrl = dependenciesUrl
    }
    
    /// Generate a Spec model for a given package.
    ///
    /// - Returns: A Spec model.
    func makeSpec() throws -> Spec {
        let spec: Spec = try decodeModel(from: specUrl)
        let dependencies: Dependencies = try decodeModel(from: dependenciesUrl)

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
                version: remoteDependency.version ?? dependency.version,
                revision: remoteDependency.revision ?? dependency.revision,
                branch: remoteDependency.branch ?? dependency.branch
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

    private func decodeModel<T: Decodable>(from url: URL) throws -> T {
        let specData = try Data(contentsOf: url)
        switch url.pathExtension {
        case "json":
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: specData)
        case "yaml", "yml":
            let decoder = YAMLDecoder()
            return try decoder.decode(T.self, from: specData)
        default:
            throw GeneratorError.invalidFormat(url.pathExtension)
        }
    }
}

// move to other file

extension URL: Comparable {
    
    public static func < (
        lhs: URL,
        rhs: URL
    ) -> Bool {
        lhs.path < rhs.path
    }
}
