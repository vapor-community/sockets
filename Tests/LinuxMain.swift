import XCTest
@testable import SocksCoreTestSuite

XCTMain([
	testCase(ConversionTests.allTests),
	testCase(LiveTests.allTests)
])
