//  Writing.swift

import Foundation

protocol Writing {
    func writePackageFile(content: String, to packageFolder: URL) throws -> Path
}
