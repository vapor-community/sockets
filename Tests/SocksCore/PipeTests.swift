//
//  PipeTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/8/16.
//
//

import XCTest
@testable import SocksCore

class PipeTests: XCTestCase {
    
    func testSendAndReceive() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        let msg = "Hello Socket".toBytes()
        try write.send(data: msg)
        let inMsg = try read.recv().toString()
        try read.close()
        try write.close()
        XCTAssertEqual(inMsg, "Hello Socket")
    }
    
    func testNoData() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        try read.close()
        try write.close()
    }
    
    func testNoSIGPIPE() throws {
        
        let (read, write) = try TCPEstablishedSocket.pipe()
        try read.close()

        let msg = "Hello Socket".toBytes()

        XCTAssertThrowsError(try write.send(data: msg)) { (error) in
            let err = error as! SocksCore.Error
            XCTAssertEqual(err.number, 32) //broken pipe
        }
        
        try write.close()
    }

}