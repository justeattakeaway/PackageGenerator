//  PackageSpec.swift

import Foundation

struct PackageSpec: Codable {
    let dependencies: [DependencySpec]
}

struct DependencySpec: Codable {
    let name: String
    let version: String
    let path: String
    let dependencies: [DependencySpec]
}
