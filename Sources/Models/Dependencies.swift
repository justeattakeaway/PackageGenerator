//  Dependencies.swift

import Foundation

struct Dependencies: Decodable {
    let dependencies: [Dependency]
}

struct Dependency: Decodable {
    let name: String
    let url: String
    let ref: Ref

    enum CodingKeys: String, CodingKey {
        case name
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        self.ref = try Ref(from: decoder)
    }

    init(name: String, url: String, ref: Ref) {
        self.name = name
        self.url = url
        self.ref = ref
    }
}
