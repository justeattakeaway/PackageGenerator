//  SpecGenerator.swift

import Foundation

/// Class to generate Specs models that can be used to ultimately generate `Package.swift` files.
final class SpecGenerator {
    
    let decoder = JSONDecoder()
    let dependenciesUrl: URL
    let modulesFolder: URL
    
    /// The default initializer.
    ///
    /// - Parameters:
    ///   - dependenciesUrl: The path  to the RemoteDependencies.json file.
    ///   - modulesFolder: The path  to the folder containing the modules.
    init(dependenciesUrl: URL, modulesFolder: URL) {
        self.dependenciesUrl = dependenciesUrl
        self.modulesFolder = modulesFolder
    }
    
    /// Generate a Spec model for a given module.
    ///
    /// - Parameter moduleName: The name of the module to generate a Spec for.
    /// - Returns: A Spec model.
    func makeSpec(for moduleName: ModuleName) throws -> Spec {
        try makeSpec(specUrl: specURL(for: moduleName))
    }
    
    /// Generate Spec models for all module.
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
                                    url: dependency.url,
                                    version: dependency.url)
        }
        
        return Spec(name: partialSpec.name,
                    localDependencies: partialSpec.localDependencies,
                    remoteDependencies: mappedDependencies,
                    products: partialSpec.products,
                    targets: partialSpec.targets)
    }
    
    private func specURL(for moduleName: ModuleName) -> URL {
        modulesFolder.appendingPathComponent("\(moduleName)/\(moduleName).json")
    }
    
    private func specURLs() throws -> [URL] {
        let fm = FileManager.default
        let contentURLs = try fm.contentsOfDirectory(at: modulesFolder,
                                                     includingPropertiesForKeys: [.nameKey],
                                                     options: .skipsHiddenFiles)
        return contentURLs.map { item in
            let moduleName = item.lastPathComponent
            return item.appendingPathComponent("\(moduleName).json")
        }
        .filter { specUrl in
            fm.fileExists(atPath: specUrl.path)
        }
        .sorted()
    }
}

extension URL: Comparable {
    
    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.path < rhs.path
    }
}
