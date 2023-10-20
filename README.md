# PackageGenerator

A tool to generate `Package.swift` files using a custom DSL allowing version alignment of dependencies across packages.


## Usage

`PackageGenerator` uses [ArgumentParser](https://github.com/apple/swift-argument-parser) and [Stencil](https://stencil.fuller.li/).

The command `generate-package` requires the following arguments:

- `path`: Path to the folder containing the packages.
- `template-path`: Path to the Stencil template.
- `dependencies-path`: Path to the `RemoteDependencies.json` file.

`RemoteDependencies.json` should contain the list of remote dependencies used by your packages. E.g.

```json
{
    "dependencies": [
        {
            "name": "Alamofire",
            "url": "https://github.com/Alamofire/Alamofire",
            "version": "5.6.1"
        },
        {
            "name": "ViewInspector",
            "url": "https://github.com/nalexn/ViewInspector",
            "version": "0.9.2"
        },
        {
            "name": "ViewInspector",
            "url": "https://github.com/nalexn/ViewInspector",
            "version": "0.9.2"
        },
        {
            "name": "SnapshotTesting",
            "url": "https://github.com/pointfreeco/swift-snapshot-testing",
            "branch": "master"
        },
        {
            "name": "Fastlane",
            "url": "https://github.com/fastlane/fastlane.git",
            "revision": "2c4f29fe161c5998e30000f96d23384fd0eebe90"
        }
    ]
}
```

Packages should be contained in respective folders inside a packages folder and provide a `<package_name>.json` spec. E.g.

```json
{
  "name": "Example",
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
      "name": "Fastlane"
    },
    {
      "name": "SnapshotTesting"
    },
  ],
  "targets": [
    {
      "name": "ExampleTarget",
      "targetType": "target",
      "dependencies": [
        {
          "name": "Alamofire"
        },
        {
          "name": "Fastlane"
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

> Note that `PackageGenerator` will automatically retrieve `url` &  ( `version` || `branch` || `revision` ) values for `remoteDependencies` from the `RemoteDependencies.json` file. If you need to override those values, you can set them in the package spec.

We provide a default Stencil template that `PackageGenerator` can work with.  

The command `generate-packages` allows you to generate Package.swift files from a given folder of packages.
It takes the same arguments as `generate-package` along with `packages-folder-path`. `PackageGenerator` will loop though subfolders and generate Package.swift files from JSON specs.

Ideally, you want to generate a `PackageGenerator` executable and automate tasks both locally and on CI.


## Demo

In the `PackageGenerator` scheme, enable 'Use custom working directory' and set the value to the folder containing the `PackageGenerator` package.
The scheme has arguments set to showcase the creation of a `Package.swift` file using some provided files.

When running the default scheme you should see a `Package.swift` file being generated in the `Packages/Example/` folder.


# Resources

This repository contains shared documents that are used for all of the open source projects provided by [Just Eat Take​away​.com](https://www.justeattakeaway.com/).

- [LICENSE](./LICENSE) contains a reference copy of the Apache 2.0 license that applies all Just Eat Takeaway.com projects. **Note**: this license needs to be included directly in each project.
- [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) describes the Code of Conduct that applies to all contributors to our projects.
