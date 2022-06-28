public typealias ShortVersion = String


public enum SwiftVersion: ShortVersion, Codable {
    case v5_3 = "5.3"
    case v5_4 = "5.4"
    case v5_5 = "5.5"
    case v5_6 = "5.6"
}


extension SwiftVersion: CaseIterable {
    public static var latest: Self { SwiftVersion.allCases.last! }

    public var isLatest: Bool { self == Self.latest }
}
