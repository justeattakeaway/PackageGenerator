//  Spec.swift

import Foundation

public typealias ModuleName = String

struct Spec: Decodable {
    let name: ModuleName
    let localDependencies: [LocalDependency]
    let remoteDependencies: [RemoteDependency]
    let targets: [Target]
    let testTargets: [TestTarget]
    let localBinaryTargets: [LocalBinaryTarget]?
    let remoteBinaryTargets: [RemoteBinaryTarget]?
    
    init(name: ModuleName,
         localDependencies: [LocalDependency],
         remoteDependencies: [RemoteDependency],
         targets: [Target],
         testTargets: [TestTarget],
         localBinaryTargets: [LocalBinaryTarget]? = nil,
         remoteBinaryTargets: [RemoteBinaryTarget]? = nil) {
        self.name = name
        self.localDependencies = localDependencies
        self.remoteDependencies = remoteDependencies
        self.targets = targets
        self.testTargets = testTargets
        self.localBinaryTargets = localBinaryTargets
        self.remoteBinaryTargets = remoteBinaryTargets
    }
}

extension Spec {
    func makeContext() -> [String: Any] {
        let values: [String: Any?] = [
            "module_name": name,
            "local_dependencies": localDependencies,
            "remote_dependencies": remoteDependencies,
            "targets": targets,
            "test_targets": testTargets,
            "local_binary_targets": localBinaryTargets,
            "remote_binary_targets": remoteBinaryTargets
        ]
        return values.compactMapValues { $0 }
    }
}

struct LocalDependency: Decodable {
    let name: String
}

struct RemoteDependency: Decodable {
    let name: String
    let url: String
    let version: String
}

typealias TestTarget = Target

struct Target: Decodable {
    let name: String
    let dependencies: [TargetDependency]
    let path: String
    let hasResources: Bool
    let swiftSettings: String?
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
