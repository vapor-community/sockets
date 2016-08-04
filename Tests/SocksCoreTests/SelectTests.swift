//
//  SelectTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/8/16.
//
//

import XCTest
@testable import SocksCore

class SelectTests: XCTestCase {
    
    func testEmpties() throws {
        let (reads, writes, errors) = try select(timeout: timeval(seconds: 0))
        XCTAssertEqual(reads.count, 0)
        XCTAssertEqual(writes.count, 0)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testOnePipeReadyToWrite() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        let (reads, writes, errors) = try select(reads: [read.descriptor],
                                                 writes: [write.descriptor],
                                                 errors: [],
                                                 timeout: timeval(seconds: 0))
        try read.close()
        try write.close()
        XCTAssertEqual(reads.count, 0)
        XCTAssertEqual(writes.count, 1)
        XCTAssertEqual(writes[0], write.descriptor)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testOnePipeReadyToReadOneToWrite() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        try write.send(data: "Heya".toBytes())
        let (reads, writes, errors) = try select(reads: [read.descriptor],
                                                 writes: [write.descriptor],
                                                 errors: [],
                                                 timeout: timeval(seconds: 0))
        try read.close()
        try write.close()
        
        XCTAssertEqual(reads.count, 1)
        XCTAssertEqual(reads[0], read.descriptor)
        XCTAssertEqual(writes.count, 1)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testTwoPipesReadyToRead() throws {
        let (read1, write1) = try TCPEstablishedSocket.pipe()
        let (read2, write2) = try TCPEstablishedSocket.pipe()
        let (read3, write3) = try TCPEstablishedSocket.pipe()
        try write1.send(data: "Heya".toBytes())
        try write3.send(data: "Socks".toBytes())
        let (reads, writes, errors) = try select(reads: [read1.descriptor, read2.descriptor, read3.descriptor],
                                                 writes: [],
                                                 errors: [],
                                                 timeout: timeval(seconds: 0))
        try read1.close()
        try write1.close()
        try read2.close()
        try write2.close()
        try read3.close()
        try write3.close()
        
        XCTAssertEqual(reads.count, 2)
        XCTAssertEqual(Set(reads), Set([read1.descriptor, read3.descriptor]))
        XCTAssertEqual(writes.count, 0)
        XCTAssertEqual(errors.count, 0)
    }

}
