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

import XCTest
@testable import SPIManifest


class SwiftVersionTests: XCTestCase {

    func test_init() throws {
        XCTAssertEqual(SwiftVersion(major: 6, minor: 3), .v6_3)
        XCTAssertEqual(SwiftVersion(major: 5, minor: 5), nil)
    }

    func test_isLatestRelease() throws {
        XCTAssertEqual(SwiftVersion.v6_0.isLatestRelease, false)
        XCTAssertEqual(SwiftVersion.v6_1.isLatestRelease, false)
        XCTAssertEqual(SwiftVersion.v6_2.isLatestRelease, false)
        XCTAssertEqual(SwiftVersion.v6_3.isLatestRelease, true)
    }

    func test_Comparable() throws {
        XCTAssert(SwiftVersion.v6_3 > .v6_2)
        XCTAssert(SwiftVersion.v6_2 > .v6_1)
        XCTAssert(SwiftVersion.v6_1 > .v6_0)
    }

}
