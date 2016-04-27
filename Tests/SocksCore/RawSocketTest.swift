//
//  RawSocketTest.swift
//  Socks
//
//  Created by Matthias Kreileder on 12/04/2016.
//
//

import XCTest
@testable import SocksCore

class RawSocketTest: XCTestCase {

    func testRawSocket(){
        let socket_Config = SocketConfig(addressFamily: .Unspecified, socketType: .Stream, protocolType: .TCP)
        let resolver = Resolver(config: socket_Config)
        
        let userProvidedInternetAddress = InternetAddress(hostname : "google.com", port : .PortNumber(80))
        let resolvedInternetAddressList = try! resolver.resolve(internetAddress: userProvidedInternetAddress)
        
        // Let's observe the addresses
        for singleResolvedInternetAddress in resolvedInternetAddressList {
            print(singleResolvedInternetAddress.resolvedCTypeAddress)
        }
        
        XCTAssertTrue(resolvedInternetAddressList.count != 0)
        
        //
        // interesting part starts here: did the socket() call succeed?
        //
        let raw = try! RawSocket(socketConfig: socket_Config, resolvedInternetAddress: resolvedInternetAddressList[0])
        
        XCTAssertTrue(raw.descriptor > 0)
        
    }



}
