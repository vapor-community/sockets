import Foundation
import XCTest
import Sockets
import Core
import Dispatch
@testable import Transport

class SockStreamTests: XCTestCase {
    static let allTests = [
        ("testTCPInternetSocket", testTCPInternetSocket),
        ("testTCPInternetSocketThrows", testTCPInternetSocketThrows),
        ("testTCPServer", testTCPServer),
        // ("testSecurityLayerStrings", testSecurityLayerStrings),
        ("testFoundationStream", testFoundationStream),
        //("testFoundationThrows", testFoundationThrows),
        ("testFoundationEventCode", testFoundationEventCode)
    ]

    func testTCPInternetSocket() throws {
        let httpBin = try TCPInternetSocket(
            hostname: "httpbin.org",
            port: 80
        )
        try httpBin.setTimeout(10)
        try httpBin.connect()
        try httpBin.send("GET /html\r\n\r\n".makeBytes())
        try httpBin.flush()
        let received = try httpBin.receive(max: 2048)
        try httpBin.close()

        print(received.makeString())
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
            try socket.send("GET /html\r\n\r\n")
            let received = try socket.receive(max: 2048)
            let str = received.makeString()
            try socket.close()

            XCTAssert(str.contains("Herman Melville - Moby-Dick"))
        } catch {
            XCTFail("Error: \(error)")
        }
    }

    func testTCPInternetSocketThrows() throws {
        let google = try TCPInternetSocket(
            hostname: "google.com",
            port: 80
        )

        do {
            try google.send("GET /\r\n\r\n".makeBytes())
            XCTFail("should throw -- not connected")
        } catch {
            // pass
        }

        do {
            _ = try google.receive(max: 2048)
            XCTFail("should throw -- not connected")
        } catch {
            // pass
        }
    }


    func testTCPServer() throws {
        background {
            do {
                let serverStream = try TCPInternetSocket(
                    hostname: "0.0.0.0",
                    port: 8692
                )
                try serverStream.bind()
                try serverStream.listen()
                let client = try serverStream.accept()
                let message = try client
                    .receive(max: 2048)
                    .makeString()
                XCTAssert(message == "Hello, World!")
            } catch {
                XCTFail("\(error)")
            }
        }

        let client = try TCPInternetSocket(
            hostname: "0.0.0.0",
            port: 8692
        )
        try client.connect()
        try client.send("Hello, World!".makeBytes())
    }

    func testFoundationStream() throws {
        let clientStream = try FoundationStream(
            hostname: "httpbin.org",
            port: 80
        )
        try clientStream.connect()
        XCTAssert(!clientStream.isClosed)
        do {
            try clientStream.setTimeout(30)
            XCTFail("Foundation stream should throw on timeout set")
        } catch {}
        try clientStream.send("GET /html\r\n\r\n".makeBytes())
        try clientStream.flush()
        let received = try clientStream.receive(max: 2048)
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
}

// import XCTest
// @testable import VaporTLS
//import TLS
//
//class TLSStreamTests: XCTestCase {
//    static var allTests = [
//        ("testSend", testSend)
//    ]
//
//    func testSend() throws {
//        let config = try Context(
//            .client,
//            verifyCertificates: false
//        )
//
//        do {
//            let clientStream = try TCPClientStream(host: "api.spotify.com", port: 443, securityLayer: .tls(config)).connect()
//            let uri = "/v1/search?type=artist&q=hannah%20diamond"
//            try clientStream.send("GET \(uri) HTTP/1.1\r\nHost: api.spotify.com\r\nAccept: */*\r\n\r\n".makeBytes())
//            let response = try clientStream.receive(max: 2048).string
//
//            XCTAssert(response.contains("spotify:artist:3sXErEOw7EmO6Sj7EgjHdU"))
//        } catch {
//            XCTFail("Could not send: \(error)")
//        }
//    }
//}
