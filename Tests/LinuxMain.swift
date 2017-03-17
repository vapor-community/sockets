import XCTest
@testable import SocketsTests
@testable import TransportTests

XCTMain([
	testCase(AddressResolutionTests.allTests),
	testCase(ConversionTests.allTests),
    testCase(LifetimeTests.allTests),
	testCase(LiveTests.allTests),
	testCase(PipeTests.allTests),
	testCase(SelectTests.allTests),
    testCase(StreamTests.allTests),
	testCase(TimeoutTests.allTests),
    testCase(StreamBufferTests.allTests)
])
