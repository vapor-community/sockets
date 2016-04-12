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
        
        let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        let resolver = Resolver(config: socket_Config)
        
        let userProvidedInternetAddress = KclInternetAddress(hostname : "google.com", port : .Portnumber(80))
        let resolvedInternetAddressList = resolver.resolve(userProvidedInternetAddress)
        
        // Let's observe the addresses
        for singleResolvedInternetAddress in resolvedInternetAddressList {
            print(singleResolvedInternetAddress.resolvedCTypeAddress)
        }
        
        XCTAssertTrue(resolvedInternetAddressList.count != 0)
    }
    
    func testgetaddrinfoCall() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
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
        addressCriteria.ai_socktype = SOCK_STREAM
        addressCriteria.ai_protocol = IPPROTO_TCP
        
        var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
        
        let getaddrinfoReturnValue = getaddrinfo(hostName, service, &addressCriteria, &servinfo)
        
        if (servinfo == nil){
            print("No address was found")
        }
        else{
            // Let's see on how many and which ip addresses this host is reachable
            while(servinfo != nil){
                print(servinfo.pointee)
                servinfo = servinfo.pointee.ai_next
            }
        }
        // 0 means address resolution succeeded
        XCTAssertTrue(getaddrinfoReturnValue == 0)
    }

}
