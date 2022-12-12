//  Writer.swift

import Foundation
import ShellOut

typealias Path = String

/// Class to write `Package.swift` content to disk.
final class Writer {
    
    /// Save the content of a module's package to disk in a `Package.swift` file and set its permissions to 444 to avoid accidental modifications.
    ///
    ///  - Parameters:
    ///    - content: The content of the package.
    ///    - modulesFolder: The path to the folder containing the modules.
    ///    - moduleName: The name of the module.
    ///  - Returns: The path of the saved `Package.swift` file.
    @discardableResult
    func writePackageFile(content: String, to modulesFolder: String, moduleName: String) throws -> Path {
        let url = URL(fileURLWithPath: modulesFolder).appendingPathComponent("\(moduleName)/Package.swift")
        try content.write(to: url, atomically: true, encoding: .utf8)
        try shellOut(to: "chmod 444", arguments: [url.path])
        return url.path
    }
}
