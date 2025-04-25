//  Writer.swift

import Foundation
import ShellOut

final class Writer: Writing {
    
    @discardableResult
    func write(content: String, folder: URL, filename: String) throws -> Path {
        let url = folder.appendingPathComponent(filename)
        try content.write(to: url, atomically: true, encoding: .utf8)
        try shellOut(to: "chmod 444", arguments: [url.path])
        return url
    }
}
