//
//  AddressResolutionTest.swift
//  Socks
//
//  Created by Matthias Kreileder on 03/04/2016.
//
//

import XCTest
@testable import SocksCore

#if os(Linux)
    import Glibc
    typealias socket_addrinfo = Glibc.addrinfo
#else
    import Darwin
    typealias socket_addrinfo = Darwin.addrinfo
#endif

class AddressResolutionTest: XCTestCase {

    func testResolver() {
        
        var socketConfig = SocketConfig(addressFamily: .unspecified, socketType: .stream, protocolType: .TCP)
        
        let resolver = Resolver(config: socketConfig)
        let userProvidedInternetAddress = InternetAddress(hostname : "google.com", port : .portNumber(80))
        let resolvedInternetAddress = try! resolver.resolve(internetAddress: userProvidedInternetAddress)
        socketConfig.addressFamily = try! resolvedInternetAddress.addressFamily()
        
        let rawSocket = try! RawSocket(socketConfig: socketConfig)
        
        let socket = InternetSocket(rawSocket: rawSocket, address: resolvedInternetAddress)
        try! socket.connect()
        try! socket.send(data: "GET / HTTP/1.1\r\n\r\n".toBytes())
        let bytes = try! socket.recv(maxBytes: 1000)
        let str = try! bytes.toString()
        let firstLine = str.characters.split(separator: "\n").map(String.init).first!
        let http11 = firstLine.characters.split(separator: " ").map(String.init).first!
        XCTAssertEqual(http11, "HTTP/1.1")
        try! socket.close()
    }
}
