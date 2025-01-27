//  Templater.swift

import Foundation
import PathKit
import Stencil
import StencilSwiftKit

typealias Content = String

/// Class to render Stencil templates.
final class Templater {
    
    let templateUrl: URL

    /// The default initializer.
    ///
    /// - Parameter templateUrl: The path to the Stencil template.
    init(templateUrl: URL) {
        self.templateUrl = templateUrl
    }
    
    /// Render a Stencil template using a given context.
    ///
    ///  - Parameters:
    ///    - context: A context to use for rendering the template.
    ///  - Returns: A rendered template.
    func renderTemplate(context: [String: Any]) throws -> Content {
        let environment = makeEnvironment()
        let filename = templateUrl.lastPathComponent
        return try environment.renderTemplate(name: filename, context: context)
    }
    
    private func makeEnvironment() -> Environment {
        let ext = Extension()
        ext.registerStencilSwiftExtensions()
        let templateFolder = templateUrl.deletingLastPathComponent().path
        let fsLoader = FileSystemLoader(paths: [PathKit.Path(stringLiteral: templateFolder)])
        var environment = Environment(loader: fsLoader, extensions: [ext])
        environment.trimBehaviour = .smart
        return environment
    }
}
