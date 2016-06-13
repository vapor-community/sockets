//
//  AddressResolutionTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/6/16.
//
//

import XCTest
@testable import SocksCore

class AddressResolutionTests: XCTestCase {
    
    func testResolutionCrashFixed() throws {
        //this tests just tries to resolve one address 100s of times
        //to make sure the intermittent crash has (most likely) been resolved
        //https://github.com/czechboy0/Socks/issues/33
        let count = 1000
        for i in 1..<count {
            let resolver = Resolver()
            let family: AddressFamily = i < 500 ? .inet : .inet6
            let address = InternetAddress(hostname: "google.com",
                                          port: 80,
                                          addressFamily: family)
            var config: SocketConfig = .TCP()
            _ = try resolver.resolve(address, with: &config)
//            print(resolved.ipString())
        }
    }
}
