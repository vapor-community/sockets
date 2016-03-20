//
//  LiveTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import XCTest
@testable import SocksCore

class LiveTests: XCTestCase {

    func testConnectLiveGoogle_HTTP() {
        
        let raw = try! RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
        let addr = InternetAddress(address: .Hostname("google.com"), port: 80)
        let socket = InternetSocket(rawSocket: raw, address: addr)
        try! socket.connect()
        try! socket.close()
        
        print("connected")
    }
    
}
