import XCTest
@testable import Fluxus

final class FluxusTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Fluxus().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
