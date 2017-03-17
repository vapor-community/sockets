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
        try httpBin.write("GET /html HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
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
            try socket.write("GET /html HTTP/1.1\r\nHost: httpbin.org\r\n\r\n")
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

        do {
            try google.write("GET /\r\n\r\n".makeBytes())
            XCTFail("should throw -- not connected")
        } catch {
            // pass
        }

        do {
            _ = try google.read(max: 2048)
            XCTFail("should throw -- not connected")
        } catch {
            // pass
        }
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
        try client.write("Hello, World!".makeBytes())
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
        try clientStream.write("GET /html HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
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
