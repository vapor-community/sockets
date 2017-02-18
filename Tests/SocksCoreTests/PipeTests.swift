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
            let err = error as! SocksCore.SocksError
            XCTAssertEqual(err.number, 32) //broken pipe
        }
        
        try write.close()
    }
    
    func testReadnSimple() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        
        let msg = "Hello Socket".toBytes()
        try write.send(data: msg)
        let inMsg = try read.readn(bytes: msg.count)
        XCTAssertEqual(msg, inMsg)
    }

    func testReadnWith2Segment() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        
        let msg_part1 = "Hello".toBytes()
        let msg_part2 = "Socket".toBytes()
       
        try write.send(data: msg_part1)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            do{
                try write.send(data: msg_part2)
            }catch{
                XCTFail("failed to send data")
            }
        }
        let inMsg = try read.readn(bytes: msg_part1.count + msg_part2.count)
        XCTAssertEqual(msg_part1 + msg_part2, inMsg)

    }
    
    
    func testReadnAndRemoteClosed() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        
        let msg_part1 = "Hello".toBytes()
        let msg_part2 = "Socket".toBytes()
        
        try write.send(data: msg_part1)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            do{
                try write.close()
            }catch{
                XCTFail("failed close write socket")
            }
        }
        let inMsg = try read.readn(bytes: msg_part1.count + msg_part2.count)
        XCTAssertEqual(msg_part1, inMsg)
        
    }


}
