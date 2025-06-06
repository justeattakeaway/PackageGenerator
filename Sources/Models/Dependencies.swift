//  Dependencies.swift

import Foundation

struct Dependencies: Decodable {
    let dependencies: [Dependency]
}

struct Dependency: Decodable {
    let name: String
    let url: String
    let identifier: String?
    let ref: Ref
    let productType: String?

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case identifier
        case productType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        self.ref = try Ref(from: decoder)
        self.productType = try container.decodeIfPresent(String.self, forKey: .productType)
    }

    init(name: String, url: String, identifier: String?, ref: Ref, productType: String?) {
        self.name = name
        self.url = url
        self.identifier = identifier
        self.ref = ref
        self.productType = productType
    }
}
