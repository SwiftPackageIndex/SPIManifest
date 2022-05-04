import XCTest
@testable import SPIManifest


class SwiftVersionTests: XCTestCase {

    func test_isLatest() throws {
        XCTAssertEqual(SwiftVersion.v5_4.isLatest, false)
        XCTAssertEqual(SwiftVersion.v5_6.isLatest, true)
    }

}
