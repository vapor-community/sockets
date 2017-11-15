import Foundation
import XCTest
@testable import Sockets

class TimeoutTests: XCTestCase {
    
    func time(_ block: () throws -> ()) rethrows -> Double {
        let start = NSDate()
        try block()
        let duration = -start.timeIntervalSinceNow
        return duration
    }
    
    func testDefaults() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        XCTAssertEqual(try read.getReceivingTimeout(), timeval(seconds: 0))
        XCTAssertEqual(try write.getSendingTimeout(), timeval(seconds: 0))
    }
    
    func testSendTimeoutSmall() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        try write.setSendingTimeout(timeval(seconds: 1))
        XCTAssertEqual(try write.getSendingTimeout(), timeval(seconds: 1))

        // HELP: how can we test a hanging send?
    }
}
