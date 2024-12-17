//  DTOLoader.swift

import Foundation
import Yams

final class DTOLoader {

    enum GeneratorError: Error {
        case invalidFormat(String)
    }

    func loadDto<T: Decodable>(url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        switch url.pathExtension {
        case "json":
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        case "yaml", "yml":
            let decoder = YAMLDecoder()
            return try decoder.decode(T.self, from: data)
        default:
            throw GeneratorError.invalidFormat(url.pathExtension)
        }
    }
}
