public enum Platform: String, Codable, CaseIterable {
    case ios
    case macosSpm           = "macos-spm"
    case macosXcodebuild    = "macos-xcodebuild"
    case tvos
    case watchos
    case linux
}
