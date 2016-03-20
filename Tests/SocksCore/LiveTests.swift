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

    func testLive_Connect_Google() {
        
        let raw = try! RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
        let addr = InternetAddress(address: .Hostname("google.com"), port: 80)
        let socket = InternetSocket(rawSocket: raw, address: addr)
        try! socket.connect()
        try! socket.close()
        print("successfully connected and closed")
    }
    
    func testLive_HTTP_Get_Google() {
        let raw = try! RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
        let addr = InternetAddress(address: .Hostname("google.com"), port: 80)
        let socket = InternetSocket(rawSocket: raw, address: addr)
        try! socket.connect()
        
        //sends a GET / request to google.com at port 80, expects a 302 redirect to HTTPS
        try! socket.send("GET /\r\n\r\n".toBytes())
        
        //receiving data
        let received = try! socket.recv()
        
        //converting data to a string
        let str = try! received.toString()
        
        //yay!
        XCTAssertTrue(received.startsWith("HTTP/1.0 ".toBytes()), "Instead received: \(str)")
        
        try! socket.close()
        print("successfully sent and received data from google.com")
    }
    
}
