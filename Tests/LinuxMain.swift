import XCTest
@testable import SocketsTests

XCTMain([
	testCase(AddressResolutionTests.allTests),
	testCase(ConversionTests.allTests),
    testCase(LifetimeTests.allTests),
	testCase(LiveTests.allTests),
	testCase(PipeTests.allTests),
	testCase(SelectTests.allTests),
    testCase(StreamTests.allTests),
	testCase(TimeoutTests.allTests)
])
