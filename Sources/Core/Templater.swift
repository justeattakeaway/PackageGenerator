//  Templater.swift

import Foundation
import PathKit
import Stencil
import StencilSwiftKit

typealias Content = String

/// Class to render Stencil templates.
final class Templater {
    
    let templatePath: String

    /// The default initializer.
    ///
    /// - Parameter templatePath: The path to the Stencil template.
    init(templatePath: String) {
        self.templatePath = templatePath
    }
    
    /// Render a Stencil template using a given context.
    ///
    ///  - Parameters:
    ///    - context: A context to use for rendering the template.
    ///  - Returns: A rendered template.
    func renderTemplate(context: [String: Any]) throws -> Content {
        let environment = makeEnvironment()
        let filename = URL(fileURLWithPath: templatePath).lastPathComponent
        return try environment.renderTemplate(name: filename, context: context)
    }
    
    private func makeEnvironment() -> Environment {
        let ext = Extension()
        ext.registerStencilSwiftExtensions()
        let templateFolder = URL(fileURLWithPath: templatePath).deletingLastPathComponent().path
        let fsLoader = FileSystemLoader(paths: [PathKit.Path(stringLiteral: templateFolder)])
        var environment = Environment(loader: fsLoader, extensions: [ext])
        environment.trimBehaviour = .smart
        return environment
    }
}
