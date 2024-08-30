//  Ref.swift

import Foundation

enum Ref: Decodable {
    case version(String)
    case revision(String)
    case branch(String)

    enum CodingKeys: String, CodingKey {
        case version
        case revision
        case branch
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let version = try container.decodeIfPresent(String.self, forKey: .version) {
            self = .version(version)
        } else if let revision = try container.decodeIfPresent(String.self, forKey: .revision) {
            self = .revision(revision)
        } else if let branch = try container.decodeIfPresent(String.self, forKey: .branch) {
            self = .branch(branch)
        } else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.version, in: container, debugDescription: "Expected one of version, revision, or branch to be present.")
        }
    }
}
