import XCTest
@testable import SocksTests
@testable import TransportTests

XCTMain([
	testCase(AddressResolutionTests.allTests),
	testCase(ConversionTests.allTests),
	testCase(LiveTests.allTests),
	testCase(PipeTests.allTests),
	testCase(SelectTests.allTests),
	testCase(TimeoutTests.allTests),
	testCase(LifetimeTests.allTests),
    testCase(StreamTests.allTests),
    testCase(StreamBufferTests.allTests)
])
