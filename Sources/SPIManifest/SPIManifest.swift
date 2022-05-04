import Yams


public typealias ShortVersion = String


public struct SPIManifest: Codable, Equatable {
    public var version: Int = 1
    public var builder: Builder

    public struct Builder: Codable, Equatable {
        public var configs: [BuildConfig]

        public struct BuildConfig: Codable, Equatable {
            public var platform: String?
            public var swiftVersion: ShortVersion?
            public var image: String?
            public var scheme: String?
            public var target: String?
            public var documentationTarget: String?

            enum CodingKeys: String, CodingKey {
                case platform
                case swiftVersion = "swift_version"
                case image
                case scheme
                case target
                case documentationTarget = "documentation_target"
            }

            public init(platform: String? = nil, swiftVersion: ShortVersion? = nil, image: String? = nil, scheme: String? = nil, target: String? = nil, documentationTarget: String? = nil) {
                self.platform = platform
                self.swiftVersion = swiftVersion
                self.image = image
                self.scheme = scheme
                self.target = target
                self.documentationTarget = documentationTarget
            }
        }

        public init(configs: [SPIManifest.Builder.BuildConfig]) {
            self.configs = configs
        }
    }

    public init(version: Int = 1, builder: SPIManifest.Builder) {
        self.version = version
        self.builder = builder
    }
}

extension SPIManifest {
    public static let fileName = ".spi.yml"

    public static func load(in directory: String = ".") -> Self? {
        let path = directory.hasSuffix("/")
            ? "\(directory)\(fileName)"
            : "\(directory)/\(fileName)"
        guard
            Current.fileManager.fileExists(path),
            let data = Current.fileManager.contents(path),
            let manifest = try? YAMLDecoder().decode(Self.self, from: data)
        else { return nil }

        return manifest
    }

    public func config(platform: Platform? = nil, swiftVersion: SwiftVersion? = nil) -> Builder.BuildConfig? {
        switch (platform, swiftVersion) {
            case let (.some(platform), .some(swiftVersion)):
                return builder.configs
                    .first {
                        $0.platform == platform.rawValue
                        && $0.swiftVersion == swiftVersion.shortVersion
                    }

            case let (.some(platform), .none):
                return builder.configs
                    .first { $0.platform == platform.rawValue }

            case let (.none, .some(swiftVersion)):
                return builder.configs
                    .first { $0.swiftVersion == swiftVersion.shortVersion }

            case (.none, .none):
                return builder.configs
                    .first { $0.platform == nil && $0.swiftVersion == nil }
        }
    }

    public func documentationTarget(platform: Platform, swiftVersion: SwiftVersion) -> String? {
        if let target = config(platform: platform,
                               swiftVersion: swiftVersion)?.documentationTarget {
            return target
        }

        // Only for the latest Swift version accept a config without a specified Swift version.
        // This will ensure that Swift versions other than the latest will not trigger a
        // documentation build and allow authors to skip specifying a Swift version in their
        // manifest, automatically always building their docs with the latest Swift version.
        if swiftVersion == .latest,
           let target = config(platform: platform)?.documentationTarget {
            return target
        } else {
            return nil
        }
    }

    public func scheme(for platform: Platform) -> String? {
        if let specific = config(platform: platform)
            .flatMap(\.scheme) {
            return specific
        }

        // look for a generic config
        return builder.configs
            .first { $0.platform == nil }
            .flatMap(\.scheme)
    }

    public func target(for platform: Platform) -> String? {
        if let specific = config(platform: platform)
            .flatMap(\.target) {
            return specific
        }

        // look for a generic config
        return builder.configs
            .first { $0.platform == nil }
            .flatMap(\.target)
    }

}