//  DependencyReference.swift

import Foundation

struct DependenciesFile: Codable {
    let dependencies: [DependencyReference]
}

struct DependencyReference: Codable, Hashable {
    let name: String
    let versionRef: String
}

extension DependencyReference: CustomStringConvertible {
    var description: String {
        """
        DependencyReference(name: \(name), versionRef: \(versionRef))
        """
    }
}
