# PackageGenerator

A tool to generate `Package.swift` files using a custom DSL allowing version alignment of dependencies across packages.


## Usage

`PackageGenerator` uses [ArgumentParser](https://github.com/apple/swift-argument-parser) and [Stencil](https://stencil.fuller.li/).

The only available command is `generate-package` that requires the following aruments:

- `modules-folder`: Path to the folder containing the modules.
- `template-path`: Path to the Stencil template.
- `dependencies-path`: Path to the `RemoteDependencies.json` file.
- `module-name`: The name of the module to generate the `Package.swift` for.

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
        }
    ]
}
```

Modules should be contained in respective folders inside a modules folder and provide a `<module_name>.json` spec. E.g.

```json
{
  "name": "Example",
  "localDependencies": [
    {
      "name": "MyLocalFramework"
    }
  ],
  "remoteDependencies": [
    {
      "name": "Alamofire",
      "url": "ALAMOFIRE_URL",
      "version": "ALAMOFIRE_VERSION"
    },
    {
      "name": "ViewInspector",
      "url": "VIEWINSPECTOR_URL",
      "version": "VIEWINSPECTOR_VERSION"
    }
  ],
  "targets": [
    {
      "name": "Example",
      "dependencies": [
        {
          "name": "Alamofire"
        }
      ],
      "path": "Framework/Sources",
      "hasResources": true
    }
  ],
  "testTargets": [
    {
      "name": "UnitTests",
      "dependencies": [
        {
          "name": "Example",
          "isTarget": true
        },
        {
          "name": "ViewInspector"
        }
      ],
      "path": "Tests/Sources",
      "hasResources": true
    }
  ]
}
```

> Note that the fields `url` and `version` of remote dependencies should be structured like in the example above so that `PackageGenerator` can lookup the correct values in `RemoteDependencies.json`. If you prefer to specify the version for a specific package, you can set the real value in the module spec.

We provide a default Stencil template that `PackageGenerator` can work with.  


Ideally, you want to generate a `PackageGenerator` executable and automate tasks both locally and on CI.


## Demo

In the `PackageGenerator` scheme, enable 'Use custom working directory' and set the value to the folder containing the `PackageGenerator` package.
The scheme has arguments set to showcase the creation of a `Package.swift` file using some provided files.

When running the default scheme you shold see a `Package.swift` file being generated in the `Modules/Example/` folder.
