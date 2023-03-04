//  SpecGenerator.swift

import Foundation

/// Class to generate Specs models that can be used to ultimately generate `Package.swift` files.
final class SpecGenerator {
    
    let decoder = JSONDecoder()
    let dependenciesUrl: URL
    let packagesFolder: URL
    
    /// The default initializer.
    ///
    /// - Parameters:
    ///   - dependenciesUrl: The path  to the RemoteDependencies.json file.
    ///   - packagesFolder: The path  to the folder containing the packages.
    init(dependenciesUrl: URL, packagesFolder: URL) {
        self.dependenciesUrl = dependenciesUrl
        self.packagesFolder = packagesFolder
    }
    
    /// Generate a Spec model for a given package.
    ///
    /// - Parameter packageName: The name of the package to generate a Spec for.
    /// - Returns: A Spec model.
    func makeSpec(for packageName: PackageName, specUrl: URL) throws -> Spec {
        try makeSpec(specUrl: specUrl)
    }
    
    /// Generate Spec models for all packages.
    ///
    /// - Returns: An array of Spec models.
    func makeSpecs() throws -> [Spec] {
        try specURLs().map(makeSpec)
    }
    
    private func makeSpec(specUrl: URL) throws -> Spec {
        let dependenciesData = try Data(contentsOf: dependenciesUrl)
        let specData = try Data(contentsOf: specUrl)
        
        let partialSpec = try decoder.decode(Spec.self, from: specData)
        let dependencies = try decoder.decode(Dependencies.self, from: dependenciesData).dependencies
        
        let mappedDependencies: [RemoteDependency] = partialSpec.remoteDependencies.compactMap { remoteDependency -> RemoteDependency? in
            guard let dependency = dependencies.first(where: { $0.name == remoteDependency.name }) else { return nil }
            return RemoteDependency(name: dependency.name,
                                    url: remoteDependency.url ?? dependency.url,
                                    version: remoteDependency.version ?? dependency.version)
        }
        
        return Spec(name: partialSpec.name,
                    localDependencies: partialSpec.localDependencies,
                    remoteDependencies: mappedDependencies,
                    products: partialSpec.products,
                    targets: partialSpec.targets)
    }
    
    private func specURL(for packageName: PackageName) -> URL {
        packagesFolder.appendingPathComponent("\(packageName)/\(packageName).json")
    }
    
    private func specURLs() throws -> [URL] {
        let fileManager = FileManager.default
        let contentURLs = try fileManager.contentsOfDirectory(at: packagesFolder,
                                                              includingPropertiesForKeys: [.nameKey],
                                                              options: .skipsHiddenFiles)
        return contentURLs.map { item in
            let packageName = item.lastPathComponent
            return item.appendingPathComponent("\(packageName).json")
        }
        .filter { specUrl in
            fileManager.fileExists(atPath: specUrl.path)
        }
        .sorted()
    }
}

extension URL: Comparable {
    
    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.path < rhs.path
    }
}
