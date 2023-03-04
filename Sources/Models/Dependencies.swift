//  Dependencies.swift

import Foundation

struct Dependencies: Decodable {
    let dependencies: [Dependency]
}

struct Dependency: Codable {
    let name: String
    var url: String
    var version: String
}
