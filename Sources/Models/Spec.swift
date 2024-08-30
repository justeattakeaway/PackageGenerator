//  Spec.swift

import Foundation

public typealias PackageName = String

struct Spec: Decodable {

    struct Product: Decodable {
        let name: String
        let productType: ProductType
        let targets: [String]

        enum CodingKeys: CodingKey {
            case name
            case productType
            case targets
        }
    }

    enum ProductType: String, Decodable {
        case library
        case executable
        case plugin
    }

    struct LocalDependency: Decodable {
        let name: String
        let path: String
    }

    struct RemoteDependency: Decodable {
        let name: String
        let url: String?
        let ref: Ref?

        enum CodingKeys: CodingKey {
            case name
            case url
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.url = try container.decodeIfPresent(String.self, forKey: .url)
            self.ref = try? Ref(from: decoder)
        }

        init(name: String, url: String, ref: Ref) {
            self.name = name
            self.url = url
            self.ref = ref
        }
    }

    enum TargetType: String, Decodable {
        case target
        case testTarget
        case executableTarget
        case plugin
    }

    struct Target: Decodable {
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

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.targetType = try container.decode(TargetType.self, forKey: .targetType).rawValue
            self.name = try container.decode(String.self, forKey: .name)
            self.dependencies = try container.decode([TargetDependency].self, forKey: .dependencies)
            self.sourcesPath = try container.decode(String.self, forKey: .sourcesPath)
            self.resourcesPath = try container.decodeIfPresent(String.self, forKey: .resourcesPath)
            self.exclude = try container.decodeIfPresent([String].self, forKey: .exclude)
            self.swiftSettings = try container.decodeIfPresent([String].self, forKey: .swiftSettings)
            self.cSettings = try container.decodeIfPresent([String].self, forKey: .cSettings)
            self.cxxSettings = try container.decodeIfPresent([String].self, forKey: .cxxSettings)
            self.linkerSettings = try container.decodeIfPresent([String].self, forKey: .linkerSettings)
            self.publicHeadersPath = try container.decodeIfPresent(String.self, forKey: .publicHeadersPath)
            self.plugins = try container.decodeIfPresent([Plugin].self, forKey: .plugins)
        }
    }

    struct Plugin: Decodable {
        let name: String
        let package: String?
    }

    struct TargetDependency: Decodable {
        let name: String
        let package: String?
        let isTarget: Bool?
    }

    struct LocalBinaryTarget: Decodable {
        let name: String
        let path: String
    }

    struct RemoteBinaryTarget: Decodable {
        let name: String
        let url: String
        let checksum: String
    }
    
    let name: PackageName
    let swiftToolsVersion: String?
    let platforms: [String]?
    let localDependencies: [LocalDependency]
    let remoteDependencies: [RemoteDependency]
    let products: [Product]
    let targets: [Target]
    let localBinaryTargets: [LocalBinaryTarget]?
    let remoteBinaryTargets: [RemoteBinaryTarget]?
    let swiftLanguageVersions: [String]?
    
    init(name: PackageName,
         platforms: [String]?,
         localDependencies: [LocalDependency],
         remoteDependencies: [RemoteDependency],
         products: [Product],
         targets: [Target],
         localBinaryTargets: [LocalBinaryTarget]? = nil,
         remoteBinaryTargets: [RemoteBinaryTarget]? = nil,
         swiftToolsVersion: String? = nil,
         swiftLanguageVersions: [String]? = nil) {
        self.name = name
        self.platforms = platforms
        self.localDependencies = localDependencies
        self.remoteDependencies = remoteDependencies
        self.products = products
        self.targets = targets
        self.localBinaryTargets = localBinaryTargets
        self.remoteBinaryTargets = remoteBinaryTargets
        self.swiftToolsVersion = swiftToolsVersion
        self.swiftLanguageVersions = swiftLanguageVersions
    }
}
