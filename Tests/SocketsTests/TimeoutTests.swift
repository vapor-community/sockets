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

    func testReceiveTimeoutTiny() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        try read.setReceivingTimeout(timeval(seconds: 0.5))
        XCTAssertEqual(try read.getReceivingTimeout(), timeval(seconds: 0.5))
        let duration = time {
            do {
                _ = try read.read(max: 2048)
                XCTFail()
            } catch {
                guard let err = error as? Sockets.SocketsError, case .readFailed = err.type else {
                    XCTFail()
                    return
                }
                #if os(Linux)
                    XCTAssertEqual(err.number, 11)
                #else
                    XCTAssertEqual(err.number, 35)
                #endif
            }
        }
        XCTAssertEqualWithAccuracy(duration, 0.5, accuracy: 0.1)
    }
    
    func testReceiveTimeoutSmall() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        try read.setReceivingTimeout(timeval(seconds: 1))
        XCTAssertEqual(try read.getReceivingTimeout(), timeval(seconds: 1))
        let duration = time {
            do {
                _ = try read.read(max: 2048)
                XCTFail()
            } catch {
                guard let err = error as? Sockets.SocketsError, case .readFailed = err.type else {
                    XCTFail()
                    return
                }
                #if os(Linux)
                    XCTAssertEqual(err.number, 11)
                #else
                    XCTAssertEqual(err.number, 35)
                #endif
            }
        }
        XCTAssertEqualWithAccuracy(duration, 1.0, accuracy: 0.1)
    }
    
    func testSendTimeoutSmall() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        try write.setSendingTimeout(timeval(seconds: 1))
        XCTAssertEqual(try write.getSendingTimeout(), timeval(seconds: 1))

        // HELP: how can we test a hanging send?
    }
}
