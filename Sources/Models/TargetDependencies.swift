//  TargetDependencies.swift

import Foundation

public enum TargetDependencyType: String, Codable, Equatable {
    case local
    case remote
    case external
    case framework
    case library
    case target
    case plugin
    case xcframework
    case registry
}

public struct TargetDependency: Decodable, Equatable {
    public let name: String
    public let product: String?
    public let type: TargetDependencyType
    public let version: String?
    public let isOptional: Bool?

    public init(name: String, product: String?, type: TargetDependencyType, version: String? = nil, isOptional: Bool? = nil) {
        self.name = name
        self.product = product
        self.type = type
        self.version = version
        self.isOptional = isOptional
    }
}

struct TargetDependencies: Decodable {
    let dependencies: [TargetDependency]

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            // We are expecting string keys, so return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var mergedDependencies: [TargetDependency] = []

        for key in container.allKeys {
            let dependenciesForKey = try container.decode([TargetDependency].self, forKey: key)
            mergedDependencies.append(contentsOf: dependenciesForKey)
        }
        
        self.dependencies = mergedDependencies
            .sorted { $0.name < $1.name }
    }
}
