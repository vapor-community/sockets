import Foundation
import XCTest
import Sockets
import Core
import Dispatch
@testable import Transport

class StreamTests: XCTestCase {
    static let allTests = [
        ("testTCPInternetSocket", testTCPInternetSocket),
        ("testDirect", testDirect),
        ("testTCPInternetSocketThrows", testTCPInternetSocketThrows),
        ("testTCPInternetSocketThrowsClosedError", testTCPInternetSocketThrowsClosedError),
        ("testTCPServer", testTCPServer),
    ]

    func testTCPInternetSocket() throws {
        let httpBin = try TCPInternetSocket(
            scheme: "http",
            hostname: "httpbin.org",
            port: 80
        )
        try httpBin.setTimeout(10)
        try httpBin.connect()
        _ = try httpBin.write("GET /html HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
        try httpBin.flush()
        let received = try httpBin.read(max: 2048)
        try httpBin.close()

        XCTAssert(
            received
                .makeString()
                .contains("Herman Melville - Moby-Dick")
        )
    }

    func testDirect() throws {
        let address = InternetAddress(hostname: "httpbin.org", port: 80)

        do {
            let socket = try TCPInternetSocket(address)
            try socket.connect()
            _ = try socket.write("GET /html HTTP/1.1\r\nHost: httpbin.org\r\n\r\n")
            let received = try socket.read(max: 2048)
            let str = received.makeString()
            try socket.close()

            XCTAssert(str.contains("Herman Melville - Moby-Dick"))
        } catch {
            XCTFail("Error: \(error)")
        }
    }

    func testTCPInternetSocketThrows() throws {
        let google = try TCPInternetSocket(
            scheme: "http",
            hostname: "google.com",
            port: 80
        )
        
        XCTAssertThrowsError(_ = try google.write("GET /\r\n\r\n".makeBytes()), "should throw -- not connected")
        XCTAssertThrowsError(_ = try google.read(max: 2048), "should throw -- not connected")
    }
    
    func testTCPInternetSocketThrowsClosedError() throws {
        let httpBin = try TCPInternetSocket(
            scheme: "http",
            hostname: "httpbin.org",
            port: 80
        )
        try httpBin.setTimeout(10)
        try httpBin.connect()
        try httpBin.close()
        
        let errorCheck = { (error: Error) -> Void in
            guard let socketError = error as? SocketsError else {
                XCTFail("thrown error must be a SocketsError")
                return
            }
            guard case .socketIsClosed = socketError.type else {
                XCTFail("thrown error must be specifically a .socketIsClosed error")
                return
            }
        }
        
        XCTAssertThrowsError(_ = try httpBin.write("GET /\r\n\r\n"), "should throw -- not connected", errorCheck)
        XCTAssertThrowsError(_ = try httpBin.read(max: 2048), "should throw -- not connected", errorCheck)
    }


    func testTCPServer() throws {
        let group = DispatchGroup()
        group.enter()
        background {
            do {
                let serverStream = try TCPInternetSocket(
                    scheme: "http",
                    hostname: "0.0.0.0",
                    port: 8692
                )
                try serverStream.bind()
                try serverStream.listen(max: 4096)
                group.leave()
                let client = try serverStream.accept()
                let message = try client
                    .read(max: 2048)
                    .makeString()
                XCTAssert(message == "Hello, World!")
                try client.close()
                
                try serverStream.close()

                XCTAssertThrowsError(_ = try serverStream.accept(), "Should fail to accept on closed server stream") {
                    XCTAssertNotNil($0 as? SocketsError, "Should throw a SocketsError")
                    if case .socketIsClosed = ($0 as! SocketsError).type {} // Swift does not have pattern matching expressions.
                    else { XCTFail("Should throw a SocketsError.socketIsClosed") }
                }
                let failConnect = try TCPInternetSocket(scheme: "http", hostname: "0.0.0.0", port: 8692)
                XCTAssertThrowsError(try failConnect.connect(), "Should not be able to connect to closed server stream") {
                    XCTAssertNotNil($0 as? SocketsError, "Should throw a SocketsError")
                    if case .connectFailed(_, _, _) = ($0 as! SocketsError).type {}
                    else { XCTFail("Should have thrown a SocketsError.connectFailed()") }
                }
            } catch {
                XCTFail("\(error)")
            }
        }

        group.wait()

        let client = try TCPInternetSocket(
            scheme: "http",
            hostname: "0.0.0.0",
            port: 8692
        )
        try client.connect()
        _ = try client.write("Hello, World!".makeBytes())
    }

    #if os(OSX) || os(iOS)
    func testFoundationStream() throws {
        let clientStream = try FoundationStream(
            scheme: "http",
            hostname: "httpbin.org",
            port: 80
        )
        try clientStream.connect()
        XCTAssert(!clientStream.isClosed)
        _ = try clientStream.write("GET /html HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
        try clientStream.flush()
        let received = try clientStream.read(max: 2048)
        try clientStream.close()

        XCTAssert(clientStream.isClosed)
        XCTAssert(
            received
                .makeString()
                .contains("Herman Melville - Moby-Dick")
        )
    }

    func testFoundationEventCode() throws {
        // will default to underlying FoundationStream for TLS.
        let clientStream = try FoundationStream(
            scheme: "http",
            hostname: "google.com",
            port: 80
        )
        try clientStream.connect()
        XCTAssertFalse(clientStream.isClosed)
        // Force Foundation.Stream delegate
        clientStream.stream(
            clientStream.input,
            handle: .endEncountered
        )
        XCTAssertTrue(clientStream.isClosed)
    }
    #endif
}
