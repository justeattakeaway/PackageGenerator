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
        try specURLs().map { specUrl in
            try makeSpec(specUrl: specUrl)
        }
    }
    
    private func makeSpec(specUrl: URL) throws -> Spec {
        let dependenciesVersionsData = try Data(contentsOf: dependenciesUrl)
        let rawSpecContent = try String(contentsOf: specUrl)
        
        let specContent: Content = try decoder
            .decode(Dependencies.self, from: dependenciesVersionsData)
            .dependencies
            .reduce(rawSpecContent, replaceContentPlaceholders)
        
        return try decoder.decode(Spec.self, from: Data(specContent.utf8))
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
    
    private func replaceContentPlaceholders(partialResult: Content, dependency: Dependency) -> Content {
        let dependencyName = dependency.name
        let versionPlaceholder = ("\(dependencyName)_version").uppercased()
        let urlPlaceholder = ("\(dependencyName)_url").uppercased()
        
        return partialResult
            .replacingOccurrences(of: versionPlaceholder, with: dependency.version)
            .replacingOccurrences(of: urlPlaceholder, with: dependency.url)
    }
}

extension URL: Comparable {

    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.path < rhs.path
    }
}
