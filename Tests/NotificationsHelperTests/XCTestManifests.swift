import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NotificationsHelperTests.allTests)
    ]
}
#endif
