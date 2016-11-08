import XCTest
@testable import SocksCoreTests

XCTMain([
	testCase(AddressResolutionTests.allTests),
	testCase(ConversionTests.allTests),
	testCase(LiveTests.allTests),
	testCase(PipeTests.allTests),
	testCase(SelectTests.allTests),
	testCase(TimeoutTests.allTests)
])
