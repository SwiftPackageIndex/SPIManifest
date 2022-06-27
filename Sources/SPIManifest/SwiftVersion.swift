public enum SwiftVersion: String, Codable {
    case v5_3 = "5.3"
    case v5_4 = "5.4"
    case v5_5 = "5.5"
    case v5_6 = "5.6"
}


extension SwiftVersion {
    public var shortVersion: String {
        switch self {
            case .v5_3:
                return "5.3"
            case .v5_4:
                return "5.4"
            case .v5_5:
                return "5.5"
            case .v5_6:
                return "5.6"
        }
    }
}


extension SwiftVersion: CaseIterable {
    public static var latest: Self { SwiftVersion.allCases.last! }

    public var isLatest: Bool { self == Self.latest }
}
