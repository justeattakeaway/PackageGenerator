//  URL+Comparable.swift

import Foundation

extension URL: @retroactive Comparable {

    public static func < (
        lhs: URL,
        rhs: URL
    ) -> Bool {
        lhs.path < rhs.path
    }
}
