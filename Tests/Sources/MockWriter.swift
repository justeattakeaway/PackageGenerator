//  MockWriter.swift

import Foundation
@testable import PackageGenerator

struct MockWriter: Writing {

    func write(content: String, folder: URL, filename: String) throws -> Path {
        let fileURL = folder
            .appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
