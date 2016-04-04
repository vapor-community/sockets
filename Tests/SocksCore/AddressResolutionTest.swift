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
    private let socket_addrinfo = Glibc.addrinfo
#else
    import Darwin
    private let socket_addrinfo = Darwin.addrinfo
#endif

class AddressResolutionTest: XCTestCase {

    func testgetaddrinfoCall() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        /*
         *  Create arguments to call getaddrinfo
         */
        let hostName = "127.0.0.1"
        // could be service or a string indicating the well-know port e.g "7" for echo service
        let service = "echo"
        
        // Narrowing down the results we will get from the getaddrinfo call
        var addressCriteria = socket_addrinfo.init()
        // IPv4 or IPv6
        addressCriteria.ai_family = AF_UNSPEC
        addressCriteria.ai_flags = AI_PASSIVE
        // Restricting to TCP
        addressCriteria.ai_socktype = SOCK_STREAM
        addressCriteria.ai_protocol = IPPROTO_TCP
        
        var servinfo = UnsafeMutablePointer<addrinfo>.init(nil)
        
        let getaddrinfoReturnValue = getaddrinfo(hostName, service, &addressCriteria, &servinfo)
        // 0 means address resolution failed
        XCTAssertTrue(getaddrinfoReturnValue != 0)
    }

}
