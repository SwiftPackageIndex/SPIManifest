// Copyright 2020-2021 Dave Verwer, Sven A. Schmidt, and other contributors.
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

import Foundation

import Yams


public struct Manifest: Codable, Equatable {
    public var version: Int = 1
    public var builder: Builder?
    public var externalLinks: ExternalLinks?

    enum CodingKeys: String, CodingKey {
        case version
        case builder
        case externalLinks = "external_links"
    }

    public struct Builder: Codable, Equatable {
        public var configs: [BuildConfig]

        public struct BuildConfig: Codable, Equatable {
            public var platform: String?
            public var swiftVersion: ShortVersion?
            public var image: String?
            public var scheme: String?
            public var target: String?
            public var documentationTargets: [String]?

            enum CodingKeys: String, CodingKey {
                case platform
                case swiftVersion = "swift_version"
                case image
                case scheme
                case target
                case documentationTargets = "documentation_targets"
            }

            public init(platform: String? = nil, swiftVersion: ShortVersion? = nil, image: String? = nil, scheme: String? = nil, target: String? = nil, documentationTargets: [String]? = nil) {
                self.platform = platform
                self.swiftVersion = swiftVersion
                self.image = image
                self.scheme = scheme
                self.target = target
                self.documentationTargets = documentationTargets
            }
        }

        public init(configs: [Manifest.Builder.BuildConfig]) {
            self.configs = configs
        }
    }

    public struct ExternalLinks: Codable, Equatable {
        public var documentation: String?

        public init(documentation: String? = nil) {
            self.documentation = documentation
        }
    }

    public init(version: Int = 1,
                builder: Manifest.Builder? = nil,
                externalLinks: Manifest.ExternalLinks? = nil) {
        self.version = version
        self.builder = builder
        self.externalLinks = externalLinks
    }

    public init(yml: String) throws {
        self = try YAMLDecoder().decode(from: yml)
    }
}

extension Manifest {
    public static let fileName = ".spi.yml"
    public static let maxByteSize = 1_000

    public static func load(in directory: String = ".", maxByteSize: Int = Self.maxByteSize) -> Self? {
        let path = directory.hasSuffix("/")
            ? "\(directory)\(fileName)"
            : "\(directory)/\(fileName)"
        guard
            Current.fileManager.fileExists(path),
            let data = Current.fileManager.contents(path),
            data.count <= maxByteSize,
            var manifest = try? YAMLDecoder().decode(Self.self, from: data)
        else { return nil }

        Self.fixPlatforms(manifest: &manifest)

        return manifest
    }

    public enum Selection<T> {
        case any
        case specific(T)
        case none
    }

    public func config(platform: Selection<Platform> = .any, swiftVersion: Selection<SwiftVersion> = .any) -> Builder.BuildConfig? {
        guard let builder = builder else { return nil }

        switch (platform, swiftVersion) {
            case (.any, .any):
                return builder.configs.first

            case let (.specific(platform), .specific(swiftVersion)):
                return builder.configs
                    .first {
                        $0.platform == platform.rawValue
                        && $0.swiftVersion == swiftVersion.rawValue
                    }

            case let (.specific(platform), .any):
                return builder.configs
                    .first { $0.platform == platform.rawValue }

            case let (.specific(platform), .none):
                return builder.configs
                    .first { $0.platform == platform.rawValue && $0.swiftVersion == nil }

            case let (.any, .specific(swiftVersion)):
                return builder.configs
                    .first { $0.swiftVersion == swiftVersion.rawValue }

            case let (.none, .specific(swiftVersion)):
                return builder.configs
                    .first { $0.platform == nil && $0.swiftVersion == swiftVersion.rawValue }

            case (.any, .none):
                return builder.configs.first { $0.swiftVersion == nil }

            case (.none, .any):
                return builder.configs.first { $0.platform == nil }

            case (.none, .none):
                return builder.configs
                    .first { $0.platform == nil && $0.swiftVersion == nil }
        }
    }

    public func allDocumentationTargets() -> [String]? {
        guard let builder = builder else { return nil }

        return builder.configs.reduce([String]()) { partialResult, config in
            partialResult + (config.documentationTargets ?? [])
        }.uniqued()
    }

    public func documentationTargets(platform: Platform, swiftVersion: SwiftVersion) -> [String]? {
        // Return an exact match if there is one
        if let targets = config(platform: .specific(platform),
                               swiftVersion: .specific(swiftVersion))?.documentationTargets {
            return targets
        }

        // Next, if the Swift version is the latest, try to find a platform match without a fixed Swift version
        if swiftVersion == .latest,
           let targets =  config(platform: .specific(platform),
                                 swiftVersion: .none)?.documentationTargets {
            return targets
        }

        // Next, if the platform is the preferred docc platform (macosSpm), try to find a Swift version match without a fixed platform
        if platform == .macosSpm,
           let targets =  config(platform: .none,
                                 swiftVersion: .specific(swiftVersion))?.documentationTargets {
            return targets
        }

        // Finally, if the platform is the preferred docc platform (macosSpm) and the Swift version is the latest, try to find a config match without any platform or Swift version
        if platform == .macosSpm,
           swiftVersion == .latest,
           let targets = config(platform: .none, swiftVersion: .none)?.documentationTargets {
            return targets
        }

        return nil
    }

    public func scheme(for platform: Platform) -> String? {
        guard let builder = builder else { return nil }

        if let specific = config(platform: .specific(platform))
            .flatMap(\.scheme) {
            return specific
        }

        // look for a generic config
        return builder.configs
            .first { $0.platform == nil }
            .flatMap(\.scheme)
    }

    public func target(for platform: Platform) -> String? {
        guard let builder = builder else { return nil }

        if let specific = config(platform: .specific(platform))
            .flatMap(\.target) {
            return specific
        }

        // look for a generic config
        return builder.configs
            .first { $0.platform == nil }
            .flatMap(\.target)
    }

}


extension Manifest {
    /// Adjust user provided platform inputs to match valid keys. For instance `macos` (which would need to be `macos-spm` to match `Platform.macosSpm`.
    /// - Parameter manifest: input `Manifest`
    private static func fixPlatforms(manifest: inout Manifest) {
        if let builder = manifest.builder {
            let configs = builder.configs.map { config -> Builder.BuildConfig in
                var config = config
                if config.platform?.lowercased() == "macos" {
                    config.platform = Platform.macosSpm.rawValue
                }
                return config
            }
            manifest.builder?.configs = configs
        }
    }
}
