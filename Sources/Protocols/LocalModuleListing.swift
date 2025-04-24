//  LocalModuleListing.swift

import Foundation

protocol LocalModuleListing {
    func listLocalModules(at path: String) throws -> [LocalModule]
}
