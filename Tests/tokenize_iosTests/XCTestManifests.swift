import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(tokenize_iosTests.allTests),
    ]
}
#endif
