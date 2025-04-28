# PackageGenerator

![Build Status](https://github.com/justeattakeaway/PackageGenerator/actions/workflows/run_tests.yml/badge.svg?branch=main)

A CLI tool to generate `Package.swift` files using a custom DSL allowing version alignment of dependencies across packages. The CLI also supports the generation of `Tuist/Package.swift` files to handle external dependencies (see [Tuist documentation](https://docs.tuist.dev/en/guides/develop/projects/dependencies)).


## Installation

Ideally, you want to use the `PackageGenerator` executable to automate tasks both locally and on CI.

You can download a build from the [release page](https://github.com/justeattakeaway/PackageGenerator/releases) or, alternatively, build it from the source code:

```bash
swift build -c release --arch x86_64 --arch arm64
```

The executable should be generated at `.build/apple/Products/Release/PackageGenerator`.


## Usage

`PackageGenerator` uses [ArgumentParser](https://github.com/apple/swift-argument-parser) and [Stencil](https://stencil.fuller.li/).

The tool provides two commands:

1. `generate-package` with the following options:

- `--spec`: Path to a package spec file (supported formats: json, yaml)
- `--package-dependencies`: Path to a package dependencies file (supported formats: json, yaml)
- `--template`: Path to a template file (supported formats: stencil)

2. `generate-tuist-package` with the following options:

- `--package-dependencies`: Path to a package dependencies file (supported formats: json, yaml)
- `--target-dependencies`: Path to a target dependencies file (supported formats: json, yaml)
- `--template`: Path to a template file (supported formats: stencil)
- `--modules-relative-path`: Path to a folder containing the modules in individual folders (default to 'Modules'). Relative to the root of the repository. Required if targetDependencies contains local dependencies.
- `--output`: Path to the output folder (default to 'Tuist').


### Generation of standard Package.swift

Example of invocation:

```
PackageGenerator generate-package \
--spec Example/Packages/Example.yaml \
--dependencies Example/Config/Dependencies.yaml \
--template Templates/Package.stencil
```

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

The package dependencies file should contain the list of dependencies used by your package(s):

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

PackageGenerator also supports treating package dependencies as binary targets in the resulting `Package.swift`. This can be useful in cases where local and remote dependencies want to be treated as cached version in the form of XCFrameworks.

For this scenario, use the following flags/options:

- `--dependencies-as-binary-targets`: flag indicating if local and remote dependencies should be converted to local XCFrameworks
- `--relative-dependencies-path`: the relative path to the folder containing the XCFrameworks organised by name and version ref (e.g. `DependencyA/1.0.0/DependencyA.xcframework`)
- `--version-refs-path`: the path to a file containing the version refs for each dependency used by the package. Content is as follows:

```json
{
    "dependencies": [
        {
            "name": "LocalDependencyA",
            "versionRef": "someVersionRefForLocalDependencyA"
        },
        {
            "name": "RemoteDependencyA",
            "versionRef": "someVersionRefForRemoteDependencyA"
        },
        {
            "name": "RemoteDependencyB",
            "versionRef": "someVersionRefForRemoteDependencyB"
        }
    ]
}
```

- `--exclusions`: list of package names to exclude from the resulting list of binary targets


### Generation of Tuist Package.swift

Example of invocation:

```
PackageGenerator generate-tuist-package \
--package-dependencies Example/Config/PackageDependencies.yml \
--target-dependencies Example/Config/TargetDependencies.yml \
--template Templates/TuistPackage.stencil \
--modules-relative-path /path/to/project/Modules \
--output /path/to/project/Tuist
```

The `Tuist/Package.swift` file used by Tuist is used to fetch dependencies to be used in projects. For this reason, a Target dependencies file listing the dependencies of the project's targets is required, in addition to a Package dependencies files.

Here are examples in both json and yaml:

```json
{
    "target_A": [
        {
            "name": "LocalDependencyA",
            "type": "local"
        },
        {
            "name": "LocalDependencyB",
            "type": "local"
        },
        {
            "name": "RemoteDependencyA",
            "type": "remote"
        },
        {
            "name": "RemoteDependencyB",
            "type": "remote"
        }
    ],
    "target_B": [
        {
            "name": "LocalDependencyA",
            "type": "local"
        },
        {
            "name": "LocalDependencyC",
            "type": "local"
        },
        {
            "name": "RemoteDependencyA",
            "type": "remote"
        },
        {
            "name": "RemoteDependencyC",
            "type": "remote"
        }
    ]
}
```

```yaml
target_A:
  - name: LocalDependencyA
    type: local
  - name: LocalDependencyB
    type: local
  - name: RemoteDependencyA
    type: remote
  - name: RemoteDependencyB
    type: remote
target_B:
  - name: LocalDependencyA
    type: local
  - name: LocalDependencyC
    type: local
  - name: RemoteDependencyA
    type: remote
  - name: RemoteDependencyC
    type: remote
```

## Demo

In the `GeneratorPackage` scheme, enable 'Use custom working directory' and set the value to the folder containing the `PackageGenerator` package.
The scheme has arguments set to showcase the creation of a `Package.swift` file using some provided files.

When running the default scheme you should see a `Package.swift` file being generated in the `Packages/Example/` folder.


# Resources

This repository contains shared documents that are used for all of the open source projects provided by [Just Eat Take​away​.com](https://www.justeattakeaway.com/).

- [LICENSE](./LICENSE) contains a reference copy of the Apache 2.0 license that applies all Just Eat Takeaway.com projects. **Note**: this license needs to be included directly in each project.
- [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) describes the Code of Conduct that applies to all contributors to our projects.
