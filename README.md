# PackageGenerator

A CLI tool to generate `Package.swift` files using a custom DSL allowing version alignment of dependencies across packages.


## Usage

`PackageGenerator` uses [ArgumentParser](https://github.com/apple/swift-argument-parser) and [Stencil](https://stencil.fuller.li/). The tool provides a single `generate-package` command requiring the following options:

- `--spec`: Path to a package spec file (supported formats: json, yaml)
- `--dependencies`: Path to a dependencies file (supported formats: json, yaml)
- `--template`: Path to a template file (supported formats: stencil)

Here are spec examples in both json and yaml:

```json
{
  "name": "Example",
  "swiftToolsVersion": "5.10",
  "swiftLanguageVersions": [
    "5.10",
    "6.0"
  ],
  "products": [
    {
      "name": "Example",
      "productType": "library",
      "targets": [
        "ExampleTarget"
      ]
    }
  ],
  "localDependencies": [
    {
      "name": "ExampleLocalDependency",
      "path": "../LocalDependencies"
    }
  ],
  "remoteDependencies": [
    {
      "name": "Alamofire"
    },
    {
      "name": "ViewInspector",
      "version": "1.2.3"
    },
    {
      "name": "SnapshotTesting"
    }
  ],
  "targets": [
    {
      "name": "ExampleTarget",
      "targetType": "target",
      "dependencies": [
        {
          "name": "Alamofire"
        }
      ],
      "sourcesPath": "Framework/Sources",
      "resourcesPath": "Resources"
    },
    {
      "name": "ExampleTargetTests",
      "targetType": "testTarget",
      "dependencies": [
        {
          "name": "ExampleTarget",
          "isTarget": true
        },
        {
          "name": "ViewInspector"
        },
        {
          "name": "SnapshotTesting"
        }
      ],
      "sourcesPath": "Tests/Sources",
      "resourcesPath": "Resources"
    }
  ]
}
```

```yaml
name: Example
swiftToolsVersion: '5.10'
swiftLanguageVersions:
  - '5.10'
  - '6.0'
products:
  - name: Example
    productType: library
    targets:
      - ExampleTarget
localDependencies:
  - name: ExampleLocalDependency
    path: "../LocalDependencies"
remoteDependencies:
  - name: Alamofire
  - name: ViewInspector
    version: 1.2.3
  - name: SnapshotTesting
targets:
  - name: ExampleTarget
    targetType: target
    dependencies:
      - name: Alamofire
    sourcesPath: Framework/Sources
    resourcesPath: Resources
  - name: ExampleTargetTests
    targetType: testTarget
    dependencies:
      - name: ExampleTarget
        isTarget: true
      - name: ViewInspector
      - name: SnapshotTesting
    sourcesPath: Tests/Sources
    resourcesPath: Resources
```

The dependencies file should contain the list of dependencies used by your package(s):

```json
{
  "dependencies": [
    {
      "name": "Alamofire",
      "url": "https://github.com/Alamofire/Alamofire",
      "version": "5.6.1"
    },
    {
      "name": "SnapshotTesting",
      "url": "https://github.com/pointfreeco/swift-snapshot-testing",
      "branch": "master"
    },
    {
      "name": "ViewInspector",
      "url": "https://github.com/nalexn/ViewInspector",
      "revision": "23d6fabc6e8f0115c94ad3af5935300c70e0b7fa"
    }
  ]
}
```

```yaml
dependencies:
  - name: Alamofire
    url: https://github.com/Alamofire/Alamofire
    version: 5.6.1
  - name: SnapshotTesting
    url: https://github.com/pointfreeco/swift-snapshot-testing
    branch: master
  - name: ViewInspector
    url: https://github.com/nalexn/ViewInspector
    revision: 23d6fabc6e8f0115c94ad3af5935300c70e0b7fa
```

> Note that `PackageGenerator` will automatically retrieve `url` &  ( `version` || `branch` || `revision` ) values for the dependencies. If you need to override those values, you can set them in the package spec.

We provide a default Stencil template we recommend using.  

Ideally, you want to use the `PackageGenerator` executable to automate tasks both locally and on CI.

You can download a build from the [release page](https://github.com/justeattakeaway/PackageGenerator/releases) or, alternatively, build it from the source code:

```bash
swift build -c release --arch x86_64 --arch arm64
```

The executable should be generated at `.build/apple/Products/Release/PackageGenerator`.


## Demo

In the `GeneratorPackage` scheme, enable 'Use custom working directory' and set the value to the folder containing the `PackageGenerator` package.
The scheme has arguments set to showcase the creation of a `Package.swift` file using some provided files.

When running the default scheme you should see a `Package.swift` file being generated in the `Packages/Example/` folder.


# Resources

This repository contains shared documents that are used for all of the open source projects provided by [Just Eat Take​away​.com](https://www.justeattakeaway.com/).

- [LICENSE](./LICENSE) contains a reference copy of the Apache 2.0 license that applies all Just Eat Takeaway.com projects. **Note**: this license needs to be included directly in each project.
- [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) describes the Code of Conduct that applies to all contributors to our projects.
