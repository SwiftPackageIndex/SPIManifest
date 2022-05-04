// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SPIManifest",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "SPIManifest", targets: ["SPIManifest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SPIManifest",
            dependencies: ["Yams"]),
        .testTarget(
            name: "SPIManifestTests",
            dependencies: ["SPIManifest"]),
    ]
)
