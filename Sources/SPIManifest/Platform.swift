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

public enum Platform: String, Codable, CaseIterable {
    case iOS                = "ios"
    case linux
    case macosSpm           = "macos-spm"
    case macosXcodebuild    = "macos-xcodebuild"
    case tvOS               = "tvos"
    case visionOS           = "visionos"
    case watchOS            = "watchos"
    case wasm
}


extension Platform {
    public init?(lenientRawValue: String) {
        // Try plain enum rawValue init
        if let platform = Platform(rawValue: lenientRawValue) {
            self = platform
            return
        }

        // Support upper case variants
        if let platform = Platform(rawValue: lenientRawValue.lowercased()) {
            self = platform
            return
        }

        // Support alternative spellings for macos, defaulting to macos-spm
        switch lenientRawValue.lowercased() {
            case "macos", "macosspm":
                self = .macosSpm
            case "macosxcodebuild":
                self = .macosXcodebuild
            default:
                return nil
        }
    }
}
