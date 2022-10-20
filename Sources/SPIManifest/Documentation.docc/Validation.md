# Validation

How to validate `.spi.yml` files.

## Overview

You can use the included `validate-spi-manifest` executable via a [command plugin](<doc:Validation#Command-Plugin>) or the [executable directly](<doc:Validation#Validation-Executable>) to validate your `.spi.yml` file.

### Command Plugin

The simplest way to validate your package is by using the command plugin. Add the following snippet to the end of you `Package.swift` manifest file:

```swift
package.dependencies.append(
    .package(url: "https://github.com/SwiftPackageIndex/SPIManifest.git", from: "0.12.0")
)
```

and then run the command

```
swift package plugin validate-spi-manifest
```

Example output:

```
❯ swift package plugin validate-spi-manifest
Building for debugging...
Build complete! (0.10s)
✅ The file is valid.
```

or in case of an error:

```
❯ swift package plugin validate-spi-manifest
Building for debugging...
Build complete! (0.10s)
🔴 The file could not be decoded: Error at path 'version': Expected to decode Int but found Scalar instead.
```

> Note: Make sure you run the command with Swift 5.7 or later. Your tools-version in the package manifest does *not* need to be set to 5.7 or higher.


### Validation Executable

#### Installation

You can build and install the validation executable by cloning this package and running `make install`:

```sh
git clone https://github.com/SwiftPackageIndex/SPIManifest.git && cd SPIManifest
make install
```

This will copy the executable to `/usr/local/bin/`. To uninstall it, run

```sh
make uninstall
```

You can also install it using [Mint](https://swiftpackageindex.com/yonaskolb/Mint):

```sh
mint install SwiftPackageIndex/SPIManifest
```

#### Validation with the Executable

Once installed, you can run the executable with the path to an `.spi.yml` to validate it:

```sh
❯ validate-spi-manifest ~/Projects/MyPackage/.spi.yml 
✅ The file is valid.
```
