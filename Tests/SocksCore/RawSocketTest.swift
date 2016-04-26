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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRawSocket(){
        let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        let resolver = Resolver(config: socket_Config)
        
        let userProvidedInternetAddress = InternetAddress(hostname : "google.com", port : .Portnumber(80))
        let resolvedInternetAddressList = resolver.resolve(internetAddress: userProvidedInternetAddress)
        
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
