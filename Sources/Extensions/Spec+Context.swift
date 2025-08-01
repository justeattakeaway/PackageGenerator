//  Spec+Context.swift

import Foundation

extension Spec.Product {
    func makeContext() -> [String: Any] {
        var retVal: [String: Any] = [
            "name": name,
            "productType": productType.rawValue,
            "targets": targets
        ]
        if productType == .library {
            retVal["libraryType"] = libraryType?.rawValue ?? Spec.LibraryType.static.rawValue
        }
        return retVal
    }
}

extension Spec.RemoteDependency {
    func makeContext(useRegistry: Bool) -> [String: Any] {
        var retVal = [
            "name": name,
            "url": url
        ]

        if useRegistry {
            retVal["identifier"] = identifier
        }

        if let ref {
            switch ref {
            case .branch(let value):
                retVal["branch"] = value
            case .revision(let value):
                retVal["revision"] = value
            case .version(let value):
                retVal["version"] = value
            }
        }
        return retVal.compactMapValues { $0 }
    }
}

extension Spec {
    var swiftToolsVersionMajor: Int? {
        guard let swiftToolsVersionString = swiftToolsVersion else { return nil }
        if let majorString = swiftToolsVersionString.components(separatedBy: ".").first {
            return Int(majorString)
        }
        return nil
    }
    
    func makeContext(useRegistry: Bool) -> [String: Any] {
        let values: [String: Any?] = [
            "package_name": name,
            "platforms": platforms,
            "local_dependencies": localDependencies,
            "remote_dependencies": remoteDependencies.map { $0.makeContext(useRegistry: useRegistry) },
            "products": products.map { $0.makeContext() },
            "targets": targets,
            "local_binary_targets": localBinaryTargets,
            "remote_binary_targets": remoteBinaryTargets,
            "swift_tools_version": swiftToolsVersion,
            "swift_tools_version_major": swiftToolsVersionMajor,
            "swift_versions": swiftLanguageVersions
        ]
        return values.compactMapValues { $0 }
    }
}
