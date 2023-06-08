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


public enum SwiftVersion: ShortVersion, Codable {
    case v5_6 = "5.6"
    case v5_7 = "5.7"
    case v5_8 = "5.8"
    case v5_9 = "5.9"
}


extension SwiftVersion: CaseIterable {
    public static var latest: Self { SwiftVersion.allCases.last! }

    public var isLatest: Bool { self == Self.latest }
}


extension SwiftVersion: CustomStringConvertible {
    public var description: String { rawValue }
}
