# Common Use Cases

The contents of a `.spi.yml` file allow package authors to configure their package when indexed by the Swift Package Index.

The following are some common use cases.


## Host DocC documentation in the Swift Package Index

Package authors can configure their package's documentation to be hosted on the Swift Package Index. In order to do so, add a `.spi.yml` file with the following content to the root of your package repository listing on or multiple targets you want to generate documentation for:

```yaml
version: 1
builder:
  configs:
    - documentation_targets: [Target1, Target2]
```

This will generate documentation on the default platform, which is macOS.

Targets will appear in the order listed in the selector dropdown in the documentation header. In particular, the first target will be the "landing page target". That means it will be the documentation module shown when the URL does not link to a specific target.

> Note: Adding a `.spi.yml` or making changes to an exiting one may take up to 24 hours for your default branch, because we collate revisions on it. Releases are processed as soon as possible, however.

> Note: Your package manifest `Package.swift` does *not* need to include the DocC plugin in order for us to host your DocC documentation. We will automatically inject it when building your documentation if we don't detect the plugin in your manifest.

If your package is not compatible with macOS, you can specify which platform to generate documentation on:

```yaml
version: 1
builder:
  configs:
    - documentation_targets: [Target1, Target2]
      platform: ios
```

> Note: We currently only support generating documentation on macOS, iOS, and Linux.


## Configure a documentation URL for existing documentation

If you already generate and host documentation for your package, you can configure a documentation URL for it instead of having the Swift Package Index generate and host it for you.

Add the following `.spi.yml` file to do so:

```yaml
version: 1
external_links:
  documentation: "https://example.com/docs"
```


## Control Targets and Schemes

The Swift Package Index determines package compatibility by attempting to build a package for a variety of platforms. Sometimes a build can fail even though a package is compatible, because we choose the wrong scheme.

Another common source of build errors is the attempt to build test targets on watchOS. We make some attempts to pick the correct scheme but this does not always succeed.

In order to guide the build system, you can configure which scheme we should pick for a given platform:


```yaml
version: 1
builder:
  configs:
  - platform: watchos
    scheme: ComposableArchitecture_watchOS
```

There is also a `target:` key in order to configure a specific target instead of a scheme, where applicable.


## Images for Linux

Package authors can also use the `.spi.yml` file to configure custom docker base images for our Linux builds.

We build packages for Linux with docker commands using the official Swift docker images:

```bash
docker run --rm -v "$PWD":/host -w /host swift:5.7 swift build
```

Some packages however have additional operating system level dependencies that the official Swift images do not provide.

If this is the case for your package, you can use our [images derived from the official Swift docker images](https://gitlab.com/finestructure/spi-images/-/blob/main/Dockerfile), which include some common Linux packages.

Here's an example:

```yaml
version: 1
builder:
  configs:
  - platform: linux
    swift_version: '5.5'
    image: registry.gitlab.com/finestructure/spi-images:basic-5.5-latest
  - platform: linux
    swift_version: '5.6'
    image: registry.gitlab.com/finestructure/spi-images:basic-5.6-latest
```

If your requirements are not included, please [open an issue](https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/new/choose).

