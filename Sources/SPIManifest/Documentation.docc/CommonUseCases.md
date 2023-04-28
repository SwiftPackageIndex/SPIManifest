# Common Use Cases

The contents of a `.spi.yml` file allow package authors to configure their package when indexed by the Swift Package Index.

The following are some common use cases.


## Host DocC documentation in the Swift Package Index

Package authors can configure their package's documentation to be hosted on the Swift Package Index. In order to do so, add a `.spi.yml` file with the following content to the root of your package repository listing one or more targets you want to generate documentation for:

```yaml
version: 1
builder:
  configs:
    - documentation_targets: [Target1, Target2]
```

This will generate documentation on the default platform, which is macOS.

Targets will appear in the order listed in the selector dropdown in the documentation header. In particular, the first target will be the "landing page target". That means it will be the documentation module shown when the URL does not link to a specific target.

> Note: Adding a `.spi.yml` or making changes to an existing one may take up to 24 hours for your default branch, because we collate revisions on it. Releases are processed as soon as possible, however.

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

## Provide custom documentation generation parameters

DocC documentation generation can be configured via command line arguments to opt into certain features for instance. Package authors can provide these flags via the `custom_documentation_parameters` key in their `.spi.yml` file:

```yml
version: 1
builder:
    configs:
    - documentation_targets: [Target]
      custom_documentation_parameters: [--include-extended-types]
```

The provided flags will be added to the `swift package generate-documentation` call when generating documentation via SPM (default).

When choosing to generate documentation on iOS, the flags will passed to `xcodebuild docbuild` via the `OTHER_DOCC_FLAGS` environment variable.

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

We build packages for Linux with docker commands using our own images based on the official Swift docker images:

```bash
docker run --rm -v "$PWD":/host -w /host registry.gitlab.com/finestructure/spi-images:basic-5.8-latest swift build
```

Our default image comes with a few dependencies pre-installed which you can review via its [`Dockerfile`](https://gitlab.com/finestructure/spi-images/-/blob/main/Dockerfile).

There might also be other, more specialised `Dockerfiles` that match your dependencies, for example [`Dockerfile.AppKid`](https://gitlab.com/finestructure/spi-images/-/blob/main/Dockerfile.AppKid). It may be worth reviewing the `Dockerfile`s in the [`spi-images` repository for matches](https://gitlab.com/finestructure/spi-images/-/tree/main).

As mentioned above, we are referencing the basic image by default, so if `Dockerfile` matches your requirements you do not need to add an `image:` clause to your `.spi.yml` file at all.

If you would like to reference a specialized `Dockerfile`, like for instance `Dockerfile.AppKid`, use the following `image:` clause:

```yaml
version: 1
builder:
  configs:
  - platform: linux
    swift_version: '5.8'
    image: registry.gitlab.com/finestructure/spi-images:AppKid-5.8-latest
```

Effectively, the image name is based on the `Dockerfile` suffix:

```
registry.gitlab.com/finestructure/spi-images:${SUFFIX}-5.8-latest
```

If your package requires additional dependencies not covered by any of the existing images, please [open an issue](https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/new/choose) so that we can either add them to the basic image if they are of a general nature or create a new specialized image.
