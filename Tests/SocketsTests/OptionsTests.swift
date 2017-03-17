import libc
import XCTest
@testable import Sockets

class OptionsTests: XCTestCase {
    
    func testSocketOptions() throws {
        let socket = try TCPInternetSocket(.localhost(port: 0))

        #if os(Linux)
        // Reuse and KeepAlive are testing randomly on osx
        try socket.setReuseAddress(true)
        let reuseAddress = try socket.getReuseAddress()
        XCTAssert(reuseAddress == true)

        try socket.setKeepAlive(true)
        let keepAlive = try socket.getKeepAlive()
        XCTAssertEqual(keepAlive, true)
        #endif

        let expectedTimeout = timeval(seconds: 0.987)
        
        try socket.setSendingTimeout(expectedTimeout)
        let sendingTimeout = try socket.getSendingTimeout()
        XCTAssertEqual(sendingTimeout, expectedTimeout)
        
        try socket.setReceivingTimeout(expectedTimeout)
        let receivingTimeout = try socket.getReceivingTimeout()
        XCTAssertEqual(receivingTimeout, expectedTimeout)
    }
    
    func testReadingSocketOptionOnClosedSocket() throws {
        let socket = try TCPInternetSocket(.localhost(port: 0))

        try socket.close()
        do {
            _ = try socket.getSendingTimeout()
        }
        catch let error as SocketsError {
            guard case ErrorReason.socketIsClosed = error.type else {
                XCTFail()
                return
            }
        }
        catch {
            XCTFail("Wrong error")
        }
        
    }
}
