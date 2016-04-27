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

    func testClientSocket() {
        
        let socket_Config = SocketConfig(addressFamily: .Unspecified, socketType: .Stream, protocolType: .TCP)
        
        let userProvidedInternetAddress = InternetAddress(hostname : "google.com", port : .PortNumber(80))
        
        let socket = try! InternetSocket(socketConfig: socket_Config, address: userProvidedInternetAddress)
        try! socket.connect()
        
        //sends a GET / request to google.com at port 80, expects a 302 redirect to HTTPS
        try! socket.send(data: "GET /\r\n\r\n".toBytes())
        
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
