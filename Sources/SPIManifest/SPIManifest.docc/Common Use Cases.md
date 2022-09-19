# Common Use Cases

Examples of common use cases with SPIManifest.


### Schemes for watchOS

You can see the popular package [`swift-composable-architecture`][1] by [Pointfree][2] making use of [this config file][3]:


```yaml
version: 1
builder:
  configs:
  - platform: watchos
    scheme: ComposableArchitecture_watchOS

```

### Images for Linux

Custom schemes aren’t all we support though. Package authors can also use the `.spi.yml` file to configure custom docker base images for our Linux builds.

We build packages for Linux with docker commands, selecting between the [various base images that Apple provide][4].

```bash
/usr/local/bin/docker run --rm -v "$PWD":/host -w /host swiftlang/swift:5.2.4 swift build --enable-test-discovery
```

The AWS library [Soto][5] is an example of a package that makes use of this feature in its [`.spi.yml` file][6]:

```yaml
version: 1
builder:
  configs:
  - platform: linux
    swift_version: '5.0'
    image: adamfowlerphoto/aws-sdk-swift:5.0
  - platform: linux
    swift_version: '5.1'
    image: adamfowlerphoto/aws-sdk-swift:5.1
  - platform: linux
    swift_version: '5.2'
    image: adamfowlerphoto/aws-sdk-swift:5.2
  - platform: linux
    swift_version: '5.3'
    image: adamfowlerphoto/aws-sdk-swift:5.3
```

[1]: https://github.com/pointfreeco/swift-composable-architecture
[2]: https://www.pointfree.co
[3]: https://github.com/pointfreeco/swift-composable-architecture/blob/main/.spi.yml
[4]: https://hub.docker.com/r/swiftlang/swift
[5]: https://swiftpackageindex.com/soto-project/soto
[6]: https://github.com/soto-project/soto/blob/main/.spi.yml
