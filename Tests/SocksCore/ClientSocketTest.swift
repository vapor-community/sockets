//
//  ClientSocketTest.swift
//  Socks
//
//  Created by Matthias Kreileder on 12/04/2016.
//
//

import XCTest
@testable import SocksCore

class ClientSocketTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testClientSocket() {
        
        let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)
        
        let userProvidedInternetAddress = KclInternetAddress(hostname : "google.com", port : .Portnumber(80))
        
        let socket = try! KclInternetSocket(socketConfig: socket_Config, address: userProvidedInternetAddress)
        try! socket.connect()
        
        //sends a GET / request to google.com at port 80, expects a 302 redirect to HTTPS
        try! socket.send("GET /\r\n\r\n".toBytes())
        
        //receiving data
        let received = try! socket.recv()
        
        //converting data to a string
        let str = try! received.toString()
        
        //yay!
        print("Received: \n\(str)")
        
        try! socket.close()
        
        print("successfully sent and received data from google.com")
    }



}
