import XCTest
@testable import Sockets

class SelectTests: XCTestCase {
    
    func testEmpties() throws {
        let (reads, writes, errors) = try select(timeout: timeval(seconds: 0))
        XCTAssertEqual(reads.count, 0)
        XCTAssertEqual(writes.count, 0)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testOnePipeReadyToWrite() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        let (reads, writes, errors) = try select(
            reads: [read.descriptor.raw],
            writes: [write.descriptor.raw],
            errors: [],
            timeout: timeval(seconds: 0)
        )
        try read.close()
        try write.close()
        XCTAssertEqual(reads.count, 0, "Wrong read count")
        XCTAssertEqual(writes.count, 1, "Wrong write count")
        XCTAssertEqual(writes.first, write.descriptor.raw)
        XCTAssertEqual(errors.count, 0, "Too many errors")
    }
    
    func testOnePipeReadyToReadOneToWrite() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        _ = try write.write("Heya".makeBytes())
        let (reads, writes, errors) = try select(
            reads: [read.descriptor.raw],
            writes: [write.descriptor.raw],
            errors: [],
            timeout: timeval(seconds: 0)
        )
        try read.close()
        try write.close()
        
        XCTAssertEqual(reads.count, 1, "Wrong read count")
        XCTAssertEqual(reads.first, read.descriptor.raw)
        XCTAssertEqual(writes.count, 1, "Wrong write count")
        XCTAssertEqual(errors.count, 0, "Too many errors")
    }
    
    func testTwoPipesReadyToRead() throws {
        let (read1, write1) = try TCPEstablishedSocket.pipe()
        let (read2, write2) = try TCPEstablishedSocket.pipe()
        let (read3, write3) = try TCPEstablishedSocket.pipe()
        _ = try write1.write("Heya".makeBytes())
        _ = try write3.write("Socks".makeBytes())
        let (reads, writes, errors) = try select(
            reads: [read1.descriptor.raw, read2.descriptor.raw, read3.descriptor.raw],
            writes: [],
            errors: [],
            timeout: timeval(seconds: 0)
        )
        try read1.close()
        try write1.close()
        try read2.close()
        try write2.close()
        try read3.close()
        try write3.close()
        
        XCTAssertEqual(reads.count, 2, "Wrong read count")
        XCTAssertEqual(Set(reads), Set([read1.descriptor.raw, read3.descriptor.raw]))
        XCTAssertEqual(writes.count, 0, "Wrong write count")
        XCTAssertEqual(errors.count, 0, "Too many errors")
    }

}
