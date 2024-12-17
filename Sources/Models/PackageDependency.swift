//  PackageDependency.swift

import Foundation

struct PackageDependency: Equatable, Hashable {

    enum PackageDependencyType: Equatable, Hashable {
        case local(hash: String)
        case remote(tag: String)
    }

    let name: String
    let type: PackageDependencyType

    var revision: String {
        switch type {
        case .local(let hash):
            return hash
        case .remote(let tag):
            return tag
        }
    }
}
