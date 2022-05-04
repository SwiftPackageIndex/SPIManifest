@testable import SPIManifest

import XCTest
import Yams


class SPIManifestTests: XCTestCase {

    func test_encode_manifest() throws {
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: Platform.watchos.rawValue, scheme: "Alamofire watchOS")
        ]))
        let str = try YAMLEncoder().encode(m)
        XCTAssertEqual(str, """
            version: 1
            builder:
              configs:
              - platform: watchos
                scheme: Alamofire watchOS

            """)
    }

    func test_load() throws {
        Current.fileManager.fileExists = { _ in true }
        Current.fileManager.contents = { _ in
            Data(
                """
                version: 1
                builder:
                  configs:
                  - platform: watchos
                    scheme: Alamofire watchOS
                """.utf8
            )
        }

        // MUT
        let m = SPIManifest.load()

        // validation
        XCTAssertEqual(m,
                       SPIManifest(builder: .init(configs: [
                        .init(platform: Platform.watchos.rawValue,
                              scheme: "Alamofire watchOS")
                       ]))
        )
    }

    func test_manifests() throws {
        // Syntax check some manifest variants
        do {
            let yml = """
                version: 1
                builder:
                  configs:
                  - scheme: Bagbutik
                    target: Bagbutik
                """

            // MUT
            let m = try YAMLDecoder().decode(SPIManifest.self, from: yml)

            // validate
            for p in Platform.allCases {
                XCTAssertEqual(m.scheme(for: p), "Bagbutik", "failed for \(p)")
                XCTAssertEqual(m.target(for: p), "Bagbutik", "failed for \(p)")
            }
        }
    }

    func test_config_platform_swiftVersion() throws {
        // Test `config` selector
        do {  // match
            let m = SPIManifest(builder: .init(configs: [
                .init(platform: Platform.ios.rawValue,
                      swiftVersion: "5.6")
            ]))

            // MUT
            XCTAssertNotNil(m.config(platform: .ios, swiftVersion: .v5_6))
        }

        do {  // no matching platform
            let m = SPIManifest(builder: .init(configs: [
                .init(platform: Platform.linux.rawValue)
            ]))

            // MUT
            XCTAssertNil(m.config(platform: .ios, swiftVersion: .v5_6))
        }

        do {  // no matching version
            let m = SPIManifest(builder: .init(configs: [
                .init(platform: Platform.linux.rawValue),
                .init(platform: Platform.ios.rawValue)
            ]))

            // MUT
            XCTAssertNil(m.config(platform: .ios, swiftVersion: .v5_6))
        }

        do {  // pick specific swift version over nil one
            let m = SPIManifest(builder: .init(configs: [
                .init(platform: Platform.ios.rawValue, scheme: "scheme-1"),
                .init(platform: Platform.ios.rawValue, swiftVersion: "5.6", scheme: "scheme-2")
            ]))

            // MUT
            XCTAssertEqual(m.config(platform: .ios, swiftVersion: .v5_6)?.scheme, "scheme-2")
        }
    }

    func test_config_platform() throws {
        // Test `config` selector
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: Platform.linux.rawValue),
            .init(platform: Platform.ios.rawValue, swiftVersion: "5.5", scheme: "scheme-1"),
            .init(platform: Platform.ios.rawValue, scheme: "scheme-2")
        ]))

        // MUT
        XCTAssertEqual(m.config(platform: .ios)?.scheme, "scheme-1")
    }

    func test_config_swiftVersion() throws {
        // Test `config` selector
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: Platform.linux.rawValue),
            .init(platform: Platform.ios.rawValue, swiftVersion: "5.6", scheme: "scheme-1"),
            .init(platform: Platform.ios.rawValue, scheme: "scheme-2")
        ]))

        // MUT
        XCTAssertEqual(m.config(swiftVersion: .v5_6)?.scheme, "scheme-1")
    }

    func test_documentationTarget() throws {
        let m = SPIManifest(builder: .init(configs: [
            .init(documentationTarget: "t0"),
            .init(platform: Platform.ios.rawValue, documentationTarget: "t1"),
            .init(platform: Platform.watchos.rawValue, documentationTarget: "t2"),
            .init(platform: Platform.watchos.rawValue, swiftVersion: "5.6", documentationTarget: "t3"),
        ]))

        // MUT
        XCTAssertEqual(m.documentationTarget(platform: .watchos, swiftVersion: .v5_6), "t3")
        XCTAssertEqual(m.documentationTarget(platform: .watchos, swiftVersion: .v5_5), nil)
        XCTAssertEqual(m.documentationTarget(platform: .macosSpm, swiftVersion: .v5_6), nil)
    }

    func test_documentationTarget_default_swiftVersion() throws {
        // Ensure an SPIManifest without Swift version specified matches latest
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: Platform.ios.rawValue, documentationTarget: "t0"),
        ]))

        // MUT
        XCTAssertEqual(m.documentationTarget(platform: .ios, swiftVersion: .latest), "t0")
        XCTAssertEqual(m.documentationTarget(platform: .macosSpm, swiftVersion: .latest), nil)
    }

    func test_scheme() throws {
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: Platform.watchos.rawValue, scheme: "Alamofire watchOS")
        ]))

        // MUT
        XCTAssertNil(m.scheme(for: .ios))
        XCTAssertEqual(m.scheme(for: .watchos), "Alamofire watchOS")
    }

    func test_scheme_all_platforms() throws {
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: nil, scheme: "Custom scheme")
        ]))

        // MUT
        XCTAssertEqual(m.scheme(for: .ios), "Custom scheme")
        XCTAssertEqual(m.scheme(for: .watchos), "Custom scheme")
    }

    func test_target() throws {
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: Platform.macosSpm.rawValue, target: "foo bar")
        ]))

        // MUT
        XCTAssertNil(m.target(for: .ios))
        XCTAssertEqual(m.target(for: .macosSpm), "foo bar")
    }

    func test_target_all_platforms() throws {
        let m = SPIManifest(builder: .init(configs: [
            .init(platform: nil, target: "Custom target")
        ]))

        // MUT
        XCTAssertEqual(m.target(for: .macosSpm), "Custom target")
        XCTAssertEqual(m.target(for: .linux), "Custom target")
    }

    func test_handle_legacy_manifests() throws {
        // Ensure we can still read outdated manifests
        Current.fileManager.fileExists = { _ in true }
        Current.fileManager.contents = { _ in
            Data(
                """
                version: 1
                builder:
                  configs:
                  - platform: ios
                    scheme: ComposableArchitecture
                  - platform: macos-xcodebuild-arm
                    scheme: ComposableArchitecture
                """.utf8
            )
        }

        // MUT
        let m = SPIManifest.load()

        // validate
        XCTAssertEqual(m?.scheme(for: .ios), "ComposableArchitecture")
    }

}
