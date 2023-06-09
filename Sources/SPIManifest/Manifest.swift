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

import Foundation

import Yams

/// A model representing the manifest configurations
public struct Manifest: Codable, Equatable {

    /// The version of the manifest
    public var version: Int = 1

    /// Metadata associated with the package, e.g. authors
    public var metadata: Metadata?

    /// Object that holds the build configurations
    public var builder: Builder?

    /// Links to pages external to SwiftPackageIndex.com
    public var externalLinks: ExternalLinks?

    enum CodingKeys: String, CodingKey {
        case version
        case metadata
        case builder
        case externalLinks = "external_links"
    }

    public struct Metadata: Codable, Equatable {
        public var authors: String?
    }

    public struct Builder: Codable, Equatable {
        public var configs: [BuildConfig]

        public struct BuildConfig: Codable, Equatable {
            public var platform: String?
            public var swiftVersion: ShortVersion?
            public var image: String?
            public var scheme: String?
            public var target: String?

            /// Define a list of targets for which documentation should be generated. The target order determines their display order and the first target is the one displayed if no target is explicitly selected by the user.
            public var documentationTargets: [String]?

            /// Define custom parameters that will be appended to the `package generate-documentation` invocation during the documentation generation process.
            public var customDocumentationParameters: [String]?

            enum CodingKeys: String, CodingKey {
                case platform
                case swiftVersion = "swift_version"
                case image
                case scheme
                case target
                case documentationTargets = "documentation_targets"
                case customDocumentationParameters = "custom_documentation_parameters"
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
                metadata: Manifest.Metadata? = nil,
                builder: Manifest.Builder? = nil,
                externalLinks: Manifest.ExternalLinks? = nil) {
        self.version = version
        self.metadata = metadata
        self.builder = builder
        self.externalLinks = externalLinks
    }

    public init(yml: String) throws {
        var manifest = try YAMLDecoder().decode(Self.self, from: yml)
        Self.fixPlatforms(manifest: &manifest)
        self = manifest
    }
}

extension Manifest {
    public static let fileName = ".spi.yml"
    public static let maxByteSize = 1_000

    public static func load(in directory: String = ".", maxByteSize: Int = Self.maxByteSize) -> Self? {
        let path = directory.hasSuffix("/")
            ? "\(directory)\(fileName)"
            : "\(directory)/\(fileName)"
        return try? load(at: path)
    }

    public static func load(at path: String) throws -> Self {
        guard Current.fileManager.fileExists(atPath: path) else {
            throw ManifestError.invalidPath(path: path)
        }

        guard let data = Current.fileManager.contents(path) else {
            throw ManifestError.noData
        }

        guard data.count <= maxByteSize else {
            throw ManifestError.fileTooLarge(size: data.count)
        }

        var manifest: Self
        do {
            manifest = try .init(yml: String(decoding: data, as: UTF8.self))
        } catch let error as DecodingError {
            switch error {
                case let .typeMismatch(_, context):
                    throw ManifestError.decodingError("""
                        Error at path '\(context.codingPath.map(\.stringValue).joined(separator: "."))': \(context.debugDescription)
                        """)

                case let .valueNotFound(_, context):
                    throw ManifestError.decodingError("""
                        Error at path '\(context.codingPath.map(\.stringValue).joined(separator: "."))': \(context.debugDescription)
                        """)

                case let .keyNotFound(key, _):
                    throw ManifestError.decodingError("""
                        Key not found: '\(key.stringValue)'.
                        """)

                case let .dataCorrupted(context):
                    throw ManifestError.decodingError("""
                        Data corrupted: '\(context.debugDescription)'
                        """)

                @unknown default:
                    throw ManifestError.decodingError("\(error)")
            }
        } catch {
            throw ManifestError.decodingError("\(error)")
        }

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

    public subscript<Value>(_ platform: Platform, _ swiftVersion: SwiftVersion, _ keypath: KeyPath<Builder.BuildConfig, Value?>) -> Value? {
        // Return an exact match if there is one
        if let value = config(platform: .specific(platform),
                              swiftVersion: .specific(swiftVersion))?[keyPath: keypath] {
            return value
        }

        // Next, if the Swift version is the latest, try to find a platform match without a fixed Swift version
        if swiftVersion == .latestRelease,
           let value =  config(platform: .specific(platform), swiftVersion: .none)?[keyPath: keypath] {
            return value
        }

        // Next, if the platform is the preferred docc platform (macosSpm), try to find a Swift version match without a fixed platform
        if platform == .macosSpm,
           let value =  config(platform: .none, swiftVersion: .specific(swiftVersion))?[keyPath: keypath] {
            return value
        }

        // Finally, if the platform is the preferred docc platform (macosSpm) and the Swift version is the latest, try to find a config match without any platform or Swift version
        if platform == .macosSpm,
           swiftVersion == .latestRelease,
           let value = config(platform: .none, swiftVersion: .none)?[keyPath: keypath] {
            return value
        }

        return nil
    }

    public func documentationTargets(platform: Platform, swiftVersion: SwiftVersion) -> [String]? {
        self[platform, swiftVersion, \.documentationTargets]?.compactMap { $0 }
    }

    public func customDocumentationParameters(platform: Platform, swiftVersion: SwiftVersion) -> [String]? {
        self[platform, swiftVersion, \.customDocumentationParameters]?.compactMap { $0 }
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
