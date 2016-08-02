//
//  LiveTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import XCTest
@testable import Socks

class LiveTests: XCTestCase {
    
//    func testLive_UDP_Server_NoLeaks() throws {
//        
//        let server = try! SynchronousUDPServer(port: 8080)
//        print("Listening on port \(server.address.port)")
//        try server.startWithHandler { (received, client) in
//            print("Echoing \(try received.toString())")
//            try client.send(bytes: received)
//            try client.close()
//        }
//    }
    
//    func testLive_TCP_Server_NoLeaks() throws {
//        
//        let server = try! SynchronousTCPServer(port: 8080)
//        print("Listening on port \(server.address.port)")
//        try server.startWithHandler { (client) in
//            let received = try client.receiveAll()
//            print("Echoing \(try received.toString())")
//            try client.send(bytes: received)
//            try client.close()
//        }
//    }
}
