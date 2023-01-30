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

@testable import SPIManifest

import XCTest

class ArrayUniquedTests: XCTestCase {
    func test_uniqued() throws {
        let array1 = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0] // No duplicates, reverse order.
        let array2 = ["a", "b", "c", "c", "d", "e"] // One duplicate, alphabetical.
        let array3 = ["a", "a", "a", "a", "a", "a"] // Only duplicates.

        // MUT
        XCTAssertEqual(array1.uniqued(), [9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        XCTAssertEqual(array2.uniqued(), ["a", "b", "c", "d", "e"])
        XCTAssertEqual(array3.uniqued(), ["a"])
    }
}
