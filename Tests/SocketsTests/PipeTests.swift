import XCTest
@testable import Sockets

class PipeTests: XCTestCase {
    
    func testSendAndReceive() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        let msg = "Hello Socket".makeBytes()
        try write.write(msg)
        let inMsg = try read.read(max: 2048).makeString()
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

        let msg = "Hello Socket".makeBytes()

        XCTAssertThrowsError(try write.write(msg)) { (error) in
            let err = error as! SocketsError
            XCTAssertEqual(err.number, 32) //broken pipe
        }
        
        try write.close()
    }

}
