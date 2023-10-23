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
    let branch: String?

    init(name: String, url: String, version: String?, revision: String?, branch: String?) {
        guard version != nil || revision != nil || branch != nil else {
            fatalError("You need to provide at least one of the following: version, revision or branch")
        }
        
        self.name = name
        self.url = url
        self.version = version
        self.revision = revision
        self.branch = branch
    }
}
