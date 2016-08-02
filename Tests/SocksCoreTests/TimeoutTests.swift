//
//  TimeoutTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/9/16.
//
//

import Foundation
import XCTest
@testable import SocksCore

class TimeoutTests: XCTestCase {
    
    func time(_ block: () throws -> ()) rethrows -> Double {
        let start = NSDate()
        try block()
        let duration = -start.timeIntervalSinceNow
        return duration
    }
    
    func testDefaults() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        XCTAssertEqual(read.receivingTimeout, timeval(seconds: 0))
        XCTAssertEqual(write.sendingTimeout, timeval(seconds: 0))
    }
    
    func testReceiveTimeoutTiny() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        read.receivingTimeout = timeval(seconds: 0.5)
        XCTAssertEqual(read.receivingTimeout, timeval(seconds: 0.5))
        let duration = time {
            do {
                _ = try read.recv()
                XCTFail()
            } catch {
                guard let err = error as? SocksCore.SocksError, case .readFailed = err.type else {
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
        read.receivingTimeout = timeval(seconds: 1)
        XCTAssertEqual(read.receivingTimeout, timeval(seconds: 1))
        let duration = time {
            do {
                _ = try read.recv()
                XCTFail()
            } catch {
                guard let err = error as? SocksCore.SocksError, case .readFailed = err.type else {
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
        write.sendingTimeout = timeval(seconds: 1)
        XCTAssertEqual(write.sendingTimeout, timeval(seconds: 1))

        // HELP: how can we test a hanging send?
    }
    
    func testReceiveDeliverAfterHalf() throws {
//        let (read, write) = try TCPEstablishedSocket.pipe()
//        defer { try! read.close() }
//        read.receivingTimeout = timeval(seconds: 2)
//        let _ = try Strand {
//            sleep(1)
//            try! write.send(data: "Hello".toBytes())
//            try! write.close()
//        }
//        let duration = try time {
//            let response = try read.recv().toString()
//            XCTAssertEqual(response, "Hello")
//        }
//        XCTAssertEqualWithAccuracy(duration, 1.0, accuracy: 0.1)
    }
    
    func testConnectTimeoutSmall() throws {

        let addr = InternetAddress(hostname: "192.168.0.150",
                                   port: 2424)
        let socket = try TCPInternetSocket(address: addr)
        defer { try! socket.close() }

        let duration = time {
            do {
                _ = try socket.connect(withTimeout: 1)
                XCTFail()
            } catch {
                guard let err = error as? SocksCore.SocksError, case .connectTimedOut = err.type else {
                    XCTFail(String(describing: error))
                    return
                }
            }
        }
        XCTAssertEqualWithAccuracy(duration, 1.0, accuracy: 0.1)
    }

}
