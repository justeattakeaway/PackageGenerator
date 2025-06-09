//  Spec.swift

import Foundation

public typealias PackageName = String

public struct Spec: Decodable {

    public struct Product: Decodable {
        let name: String
        let productType: ProductType
        let libraryType: LibraryType?
        let targets: [String]

        enum CodingKeys: CodingKey {
            case name
            case productType
            case libraryType
            case targets
        }
    }

    public enum LibraryType: String, Decodable {
        case `static`
        case dynamic
    }

    public enum ProductType: String, Decodable {
        case library
        case executable
        case plugin
    }

    public struct LocalDependency: Decodable {
        let name: String
        let path: String
    }

    public struct RemoteDependency: Decodable {
        let name: String
        let url: String?
        let identifier: String?
        let ref: Ref?

        enum CodingKeys: CodingKey {
            case name
            case url
            case identifier
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.url = try container.decodeIfPresent(String.self, forKey: .url)
            self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
            self.ref = try? Ref(from: decoder)
        }

        init(name: String, url: String, identifier: String?, ref: Ref) {
            self.name = name
            self.url = url
            self.identifier = identifier
            self.ref = ref
        }
    }

    public enum TargetType: String, Decodable {
        case target
        case testTarget
        case executableTarget
        case plugin
    }

    public struct Target: Decodable {
        let targetType: String
        let name: String
        let dependencies: [TargetDependency]
        let sourcesPath: String
        let resourcesPath: String?
        let exclude: [String]?
        let swiftSettings: [String]?
        let cSettings: [String]?
        let cxxSettings: [String]?
        let linkerSettings: [String]?
        let publicHeadersPath: String?
        let plugins: [Plugin]?

        enum CodingKeys: CodingKey {
            case targetType
            case name
            case dependencies
            case sourcesPath
            case resourcesPath
            case exclude
            case swiftSettings
            case cSettings
            case cxxSettings
            case linkerSettings
            case publicHeadersPath
            case plugins
        }
    }

    public struct Plugin: Decodable {
        let name: String
        let package: String?
    }

    public struct TargetDependency: Decodable {
        let name: String
        let package: String?
        let dependency: String?
        let isTarget: Bool?
    }

    public struct LocalBinaryTarget: Decodable {
        let name: String
        let path: String
    }

    public struct RemoteBinaryTarget: Decodable {
        let name: String
        let url: String
        let checksum: String
    }
    
    let name: PackageName
    let platforms: [String]?
    let localDependencies: [LocalDependency]
    let remoteDependencies: [RemoteDependency]
    let products: [Product]
    let targets: [Target]
    let localBinaryTargets: [LocalBinaryTarget]?
    let remoteBinaryTargets: [RemoteBinaryTarget]?
    let swiftToolsVersion: String?
    let swiftLanguageVersions: [String]?
}
