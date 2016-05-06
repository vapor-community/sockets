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
        
        var socketConfig = SocketConfig(addressFamily: .Unspecified, socketType: .Stream, protocolType: .TCP)
        
        let resolver = Resolver(config: socketConfig)
        let userProvidedInternetAddress = InternetAddress(hostname : "google.com", port : .PortNumber(80))
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
    
    func testgetaddrinfoCall() {
        /*
         *  Create arguments to call getaddrinfo
         */
        let hostName = "www.google.com"
        // could be service or a string indicating the well-know port e.g "7" for echo service
        let service = "80"
        
        // Narrowing down the results we will get from the getaddrinfo call
        var addressCriteria = socket_addrinfo.init()
        // IPv4 or IPv6
        addressCriteria.ai_family = AF_UNSPEC
        addressCriteria.ai_flags = AI_PASSIVE
        // Restricting to TCP
        #if os(Linux)
            addressCriteria.ai_socktype = Int32(SOCK_STREAM.rawValue)
            addressCriteria.ai_protocol = Int32(IPPROTO_TCP)
        #else
            addressCriteria.ai_socktype = SOCK_STREAM
            addressCriteria.ai_protocol = IPPROTO_TCP
        #endif
        
        var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
        
        let getaddrinfoReturnValue = getaddrinfo(hostName, service, &addressCriteria, &servinfo)
        
        if (servinfo == nil){
            print("No address was found")
        }
        else{
            // Let's see on how many and which ip addresses this host is reachable
            while(servinfo != nil){
                servinfo = servinfo?.pointee.ai_next
            }
        }
        // 0 means address resolution succeeded
        XCTAssertTrue(getaddrinfoReturnValue == 0)
    }
    
}
