//  MockLocalModuleLister.swift

import Foundation
@testable import PackageGenerator

struct MockLocalModuleLister: LocalModuleListing {

    func listLocalModules(at path: String) throws -> [LocalModule] {
        [
            LocalModule(name: "ModA", relativePath: "../Modules/ModA"),
            LocalModule(name: "ModB", relativePath: "../Modules/ModB"),
            LocalModule(name: "ModC", relativePath: "../Modules/ModC")
        ]
    }
}
