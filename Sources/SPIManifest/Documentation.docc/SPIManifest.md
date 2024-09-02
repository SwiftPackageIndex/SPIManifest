# ``SPIManifest``

Control how the Swift Package Index indexes your package.

## Overview

SPIManifest is a Swift package to decode the Swift Package Index Manifest file `.spi.yml`, which Swift package authors 
can add to their repository. This allows authors a level of control over package processing by the Swift Package Index.

### Common Use Cases

Here are some examples of things that can be configured by this file:

- <doc:CommonUseCases#Host-DocC-documentation-in-the-Swift-Package-Index>
- <doc:CommonUseCases#Configure-a-documentation-URL-for-existing-documentation>
- <doc:CommonUseCases#Control-Targets-and-Schemes>

### Validation

Swift Package Index manifests can be validated for correctness via the [Online Validator](https://swiftpackageindex.com/validate-spi-manifest). 

See <doc:ManifestValidation> for more details.

## Topics

### Essentials

- <doc:CommonUseCases>
- <doc:ManifestValidation>
- <doc:MailMapFile>
- ``Manifest``
