//  Writer.swift

import Foundation
import ShellOut

typealias Path = String

/// Class to write `Package.swift` content to disk.
final class Writer {
    
    /// Save the generated `Package.swift` file and set its permissions to 444 to avoid accidental modifications.
    ///
    ///  - Parameters:
    ///    - content: The content of the package.
    ///    - packageFolder: The path to the folder containing the package.
    ///  - Returns: The path of the saved `Package.swift` file.
    @discardableResult
    func writePackageFile(content: String, to packageFolder: URL) throws -> Path {
        let url = packageFolder.appendingPathComponent("Package.swift")
        try content.write(to: url, atomically: true, encoding: .utf8)
        try shellOut(to: "chmod 444", arguments: [url.path])
        return url.path
    }
}
