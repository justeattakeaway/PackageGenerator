//  Dependencies.swift

import Foundation

struct Dependencies: Decodable {
    let dependencies: [Dependency]
}

struct Dependency: Decodable {
    let name: String
    let url: String
    let version: String?
    let revision: String?
}
