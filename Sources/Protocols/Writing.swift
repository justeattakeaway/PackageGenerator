//  Writing.swift

import Foundation

typealias Path = URL

protocol Writing {
    func write(content: String, folder: URL, filename: String) throws -> Path
}
