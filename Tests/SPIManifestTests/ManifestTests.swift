// Copyright Dave Verwer, Sven A. Schmidt, and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import SPIManifest

import XCTest
import Yams


class ManifestTests: XCTestCase {

    func test_empty() throws {
        XCTAssertNoThrow(try Manifest(yml: "version: 1"))
    }

    func test_encode_manifest() throws {
        let m = Manifest(metadata: .init(authors: "Author One and Author Two"),
                         builder: .init(configs: [
                            .init(platform: Platform.watchos.rawValue, scheme: "Alamofire watchOS")
                         ])
        )

        let str = try YAMLEncoder().encode(m)
        XCTAssertEqual(str, """
            version: 1
            metadata:
              authors: Author One and Author Two
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
                metadata:
                  authors: Author One and Author Two
                builder:
                  configs:
                  - platform: watchos
                    scheme: Alamofire watchOS
                """.utf8
            )
        }

        // MUT
        let m = Manifest.load()

        // validation
        XCTAssertEqual(m,
                       Manifest(metadata: .init(authors: "Author One and Author Two"),
                                builder: .init(configs: [
                        .init(platform: Platform.watchos.rawValue,
                              scheme: "Alamofire watchOS")
                       ]))
        )
    }

    func test_load_maxSize() throws {
        let data = Data("""
                version: 1
                builder:
                  configs:
                  - platform: macosSpm
                    swift_version: 5.6
                    scheme: Some scheme
                """.utf8)
        XCTAssertEqual(data.count, 100)
        Current.fileManager.fileExists = { _ in true }
        Current.fileManager.contents = { _ in data }

        // MUT
        XCTAssertNotNil(Manifest.load(maxByteSize: 100))
        XCTAssertNotNil(Manifest.load(maxByteSize: 101))
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
            let m = try YAMLDecoder().decode(Manifest.self, from: yml)

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
            let m = Manifest(builder: .init(configs: [
                .init(platform: Platform.ios.rawValue,
                      swiftVersion: "5.6")
            ]))

            // MUT
            XCTAssertNotNil(m.config(platform: .specific(.ios), swiftVersion: .specific(.v5_6)))
        }

        do {  // no matching platform
            let m = Manifest(builder: .init(configs: [
                .init(platform: Platform.linux.rawValue)
            ]))

            // MUT
            XCTAssertNil(m.config(platform: .specific(.ios), swiftVersion: .specific(.v5_6)))
        }

        do {  // no matching version
            let m = Manifest(builder: .init(configs: [
                .init(platform: Platform.linux.rawValue),
                .init(platform: Platform.ios.rawValue)
            ]))

            // MUT
            XCTAssertNil(m.config(platform: .specific(.ios), swiftVersion: .specific(.v5_6)))
        }

        do {  // pick specific swift version over nil one
            let m = Manifest(builder: .init(configs: [
                .init(platform: Platform.ios.rawValue, scheme: "scheme-1"),
                .init(platform: Platform.ios.rawValue, swiftVersion: "5.6", scheme: "scheme-2")
            ]))

            // MUT
            XCTAssertEqual(m.config(platform: .specific(.ios), swiftVersion: .specific(.v5_6))?.scheme, "scheme-2")
        }
    }

    func test_config_platform() throws {
        // Test `config` selector
        let m = Manifest(builder: .init(configs: [
            .init(platform: Platform.linux.rawValue),
            .init(platform: Platform.ios.rawValue, swiftVersion: "5.5", scheme: "scheme-1"),
            .init(platform: Platform.ios.rawValue, scheme: "scheme-2")
        ]))

        // MUT
        XCTAssertEqual(m.config(platform: .specific(.ios))?.scheme, "scheme-1")
    }

    func test_config_swiftVersion() throws {
        // Test `config` selector
        let m = Manifest(builder: .init(configs: [
            .init(platform: Platform.linux.rawValue),
            .init(platform: Platform.ios.rawValue, swiftVersion: "5.6", scheme: "scheme-1"),
            .init(platform: Platform.ios.rawValue, scheme: "scheme-2")
        ]))

        // MUT
        XCTAssertEqual(m.config(swiftVersion: .specific(.v5_6))?.scheme, "scheme-1")
    }

    func test_documentationTargets_bare_default() throws {
        // Ensure a "bare" documentation target setting only "selects" for macos-spm/latest
        let m = try Manifest(yml: """
            version: 1
            builder:
              configs:
              - documentation_targets: [t0]
            """
        )

        for s in SwiftVersion.allCases {
            for p in Platform.allCases {
                if p == .macosSpm && s == .latest {
                    XCTAssertEqual(
                        m.documentationTargets(platform: p, swiftVersion: s), ["t0"],
                        "failed for (\(p), \(s))"
                    )
                } else {
                    XCTAssertEqual(
                        m.documentationTargets(platform: p, swiftVersion: s), nil,
                        "failed for (\(p), \(s))"
                    )
                }
            }
        }
    }

    func test_documentationTargets_platform_default() throws {
        // Ensure a "platform specific" documentation target setting only "selects" for platform/latest
        let m = try Manifest(yml: """
            version: 1
            builder:
              configs:
              - documentation_targets: [t0]
                platform: ios
            """
        )

        for s in SwiftVersion.allCases {
            for p in Platform.allCases {
                if p == .ios && s == .latest {
                    XCTAssertEqual(
                        m.documentationTargets(platform: p, swiftVersion: s), ["t0"],
                        "failed for (\(p), \(s))"
                    )
                } else {
                    XCTAssertEqual(
                        m.documentationTargets(platform: p, swiftVersion: s), nil,
                        "failed for (\(p), \(s))"
                    )
                }
            }
        }
    }

    func test_documentationTargets_swiftVersion_default() throws {
        // Ensure a "swiftVersion specific" documentation target setting only "selects" for macos-spm/swiftVersion
        let m = try Manifest(yml: """
            version: 1
            builder:
              configs:
              - documentation_targets: [t0]
                swift_version: 5.5
            """
        )

        for s in SwiftVersion.allCases {
            for p in Platform.allCases {
                if p == .macosSpm && s == .v5_5 {
                    XCTAssertEqual(
                        m.documentationTargets(platform: p, swiftVersion: s), ["t0"],
                        "failed for (\(p), \(s))"
                    )
                } else {
                    XCTAssertEqual(
                        m.documentationTargets(platform: p, swiftVersion: s), nil,
                        "failed for (\(p), \(s))"
                    )
                }
            }
        }
    }

    func test_documentationTargets_multiple_default() throws {
        // Ensure that if multiple underspecified documentation target settings are present, the platform one is selected (i.e. we build for the latest Swift version)
        let m = try Manifest(yml: """
            version: 1
            builder:
              configs:
              - documentation_targets: [t0]
                swift_version: 5.5
              - documentation_targets: [t0]
                platform: ios
            """
        )

        for s in SwiftVersion.allCases {
            for p in Platform.allCases {
                switch (p, s) {
                    case (.ios, .latest), (.macosSpm, .v5_5):
                        XCTAssertEqual(
                            m.documentationTargets(platform: p, swiftVersion: s), ["t0"],
                            "failed for (\(p), \(s))"
                        )

                    default:
                        XCTAssertEqual(
                            m.documentationTargets(platform: p, swiftVersion: s), nil,
                            "failed for (\(p), \(s))"
                        )
                }
            }
        }
    }

    func test_documentationTargets_complex() throws {
        // Tests a more complex configuration
        let m = try Manifest(yml: """
            version: 1
            builder:
              configs:
              - documentation_targets:
                - t0
              - platform: ios
                documentation_targets:
                - t1
              - platform: watchos
                documentation_targets:
                - t2
              - platform: watchos
                swift_version: '5.6'
                documentation_targets:
                - t3
            """
        )

        // MUT
        XCTAssertEqual(m.documentationTargets(platform: .watchos, swiftVersion: .v5_6), ["t3"])
        XCTAssertEqual(m.documentationTargets(platform: .watchos, swiftVersion: .v5_5), nil)
        XCTAssertEqual(m.documentationTargets(platform: .macosSpm, swiftVersion: .v5_7), ["t0"])
    }

    func test_allDocumentationTargets() throws {
        // Test extracting a list of all documentation targets
        do {
            let m = try Manifest(yml: """
                version: 1
                builder:
                  configs:
                  - documentation_targets: [t0]
                """)
            XCTAssertEqual(m.allDocumentationTargets(), ["t0"])
        }
        do {
            let m = try Manifest(yml: """
                version: 1
                builder:
                  configs:
                  - documentation_targets: [t0]
                  - documentation_targets: [t0]
                """)
            XCTAssertEqual(m.allDocumentationTargets(), ["t0"])
        }
        do {
            let m = try Manifest(yml: """
                version: 1
                builder:
                  configs:
                  - documentation_targets: [t0]
                  - platform: ios
                    documentation_targets: [t1]
                  - platform: watchos
                    documentation_targets: [t2]
                  - platform: watchos
                    swift_version: '5.6'
                    documentation_targets: [t3]
                """)
            XCTAssertEqual(m.allDocumentationTargets(), ["t0", "t1", "t2", "t3"])
        }
        do {
            // Test maintaining order.
            let m = try Manifest(yml: """
                version: 1
                builder:
                  configs:
                  - documentation_targets: [t4, t3, t2]
                  - documentation_targets: [t2, t1, t0]
                """)
            XCTAssertEqual(m.allDocumentationTargets(), ["t4", "t3", "t2", "t1", "t0"])
        }
    }

    func test_scheme() throws {
        let m = Manifest(builder: .init(configs: [
            .init(platform: Platform.watchos.rawValue, scheme: "Alamofire watchOS")
        ]))

        // MUT
        XCTAssertNil(m.scheme(for: .ios))
        XCTAssertEqual(m.scheme(for: .watchos), "Alamofire watchOS")
    }

    func test_scheme_all_platforms() throws {
        let m = Manifest(builder: .init(configs: [
            .init(platform: nil, scheme: "Custom scheme")
        ]))

        // MUT
        XCTAssertEqual(m.scheme(for: .ios), "Custom scheme")
        XCTAssertEqual(m.scheme(for: .watchos), "Custom scheme")
    }

    func test_target() throws {
        let m = Manifest(builder: .init(configs: [
            .init(platform: Platform.macosSpm.rawValue, target: "foo bar")
        ]))

        // MUT
        XCTAssertNil(m.target(for: .ios))
        XCTAssertEqual(m.target(for: .macosSpm), "foo bar")
    }

    func test_target_all_platforms() throws {
        let m = Manifest(builder: .init(configs: [
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
        let m = Manifest.load()

        // validate
        XCTAssertEqual(m?.scheme(for: .ios), "ComposableArchitecture")
    }

    func test_documentationUrl() throws {
        do {
            let m = try Manifest(yml: """
                version: 1
                external_links:
                  documentation: https://example.com/package/documentation/
                """)

            let externalLinks = try XCTUnwrap(m.externalLinks)
            XCTAssertEqual(externalLinks.documentation, "https://example.com/package/documentation/")
        }
    }

    func test_macos_platform() throws {
        // Ensure we interpret platform key `macos` as `macos-spm`
        // https://github.com/SwiftPackageIndex/SPIManifest/issues/11
        Current.fileManager.fileExists = { _ in true }
        Current.fileManager.contents = { _ in
            Data(
                """
                version: 1
                builder:
                  configs:
                  - platform: macos
                    target: foo
                """.utf8
            )
        }

        // MUT
        let m = Manifest.load()

        // validation
        XCTAssertEqual(m,
                       Manifest(builder: .init(configs: [
                        .init(platform: Platform.macosSpm.rawValue,
                              target: "foo")
                       ]))
        )
    }

    func test_customDocumentationParameters() throws {
        let m = try Manifest(yml: """
            version: 1
            builder:
              configs:
              - documentation_targets: [t0]
                custom_documentation_parameters:
                - --foo
                - bar
            """
        )

        XCTAssertEqual(
            m.customDocumentationParameters(platform: .macosSpm, swiftVersion: .latest),
            ["--foo", "bar"]
        )
    }

}
