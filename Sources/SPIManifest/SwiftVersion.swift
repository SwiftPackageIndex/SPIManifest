enum SwiftVersion: String, Codable {
    case v5_3 = "5.3.3"
    case v5_4 = "5.4.0"
    case v5_5 = "5.5.2"
    case v5_6 = "5.6.0"
}


extension SwiftVersion {
    var xcodeVersion: String {
        switch self {
            case .v5_3:
                return "Xcode-12.4.0"
            case .v5_4:
                return "Xcode-12.5.1"
            case .v5_5:
                return "Xcode-13.2.1"
            case .v5_6:
                // Update the Xcode version in the Makefile when changing this version
                return "Xcode-13.3.0"
        }
    }

    var dockerImage: String {
        switch self {
            case .v5_3:
                return "swift:5.3"
            case .v5_4:
                return "swift:5.4"
            case .v5_5:
                return "swift:5.5.2"
            case .v5_6:
                return "swift:5.6.0"
        }
    }

    var developerDir: String {
        "/Applications/\(xcodeVersion).app"
    }

    var shortVersion: String {
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
    static var latest: Self { SwiftVersion.allCases.last! }

    var isLatest: Bool { self == Self.latest }
}
