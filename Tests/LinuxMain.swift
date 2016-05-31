import XCTest
@testable import SocksCoreTestSuite

XCTMain([
	testCase(ConversionTests.allTests),
	testCase(LiveTests.allTests),
	testCase(RawSocketTest.allTests),
	testCase(AddressResolutionTest.allTests),
	testCase(ClientSocketTest.allTests)
])
