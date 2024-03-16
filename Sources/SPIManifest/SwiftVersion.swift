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

public typealias ShortVersion = String


public enum SwiftVersion: ShortVersion, Codable, CaseIterable {
    case v5_7 = "5.7"
    case v5_8 = "5.8"
    case v5_9 = "5.9"
    case v5_10 = "5.10"
    case v6_0 = "6.0"

    public static var latestRelease: Self { .v5_10 }

    public init?(major: Int, minor: Int) {
        self.init(rawValue: "\(major).\(minor)")
    }
}


extension SwiftVersion {
    public var isLatestRelease: Bool { self == Self.latestRelease }
}


extension SwiftVersion: CustomStringConvertible {
    public var description: String { rawValue }
}


extension SwiftVersion: Comparable {
    public static func < (lhs: SwiftVersion, rhs: SwiftVersion) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
