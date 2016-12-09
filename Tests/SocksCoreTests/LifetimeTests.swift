import XCTest
@testable import SocksCore

class LifetimeTests: XCTestCase {
    
    func testStoppingTCPInternetSocket() throws {
        let socket = try TCPInternetSocket(address: .localhost(port: 0))

        // file descriptor should be open
        let fdFlagOpen = fcntl(socket.descriptor, F_GETFD)
        XCTAssertEqual(fdFlagOpen, 0)
        
        try socket.close()
        
        // file descriptor should be closed
        let fdFlagClosed = fcntl(socket.descriptor, F_GETFD)
        XCTAssertEqual(fdFlagClosed, -1)
        
        // attempt to close a second again; shouldn't throw
        try socket.close()
    }

    func testStoppingUDPSocket() throws {
        let socket = try UDPInternetSocket(address: .localhost(port: 0))
        
        // file descriptor should be open
        let fdFlagOpen = fcntl(socket.descriptor, F_GETFD)
        XCTAssertEqual(fdFlagOpen, 0)
        
        try socket.close()
        
        // file descriptor should be closed
        let fdFlagClosed = fcntl(socket.descriptor, F_GETFD)
        XCTAssertEqual(fdFlagClosed, -1)
        
        // attempt to close a second again; shouldn't throw
        try socket.close()
    }

    func testReleasingTCPInternetSocket() throws {
        var optionalSocket:TCPInternetSocket? = try TCPInternetSocket(address: .localhost(port: 0))
        
        guard let descriptor = optionalSocket?.descriptor else {
            XCTFail("Failed to get descriptor")
            return
        }
        
        if let socket = optionalSocket {
            // file descriptor should be open
            let fdFlagOpen = fcntl(socket.descriptor, F_GETFD)
            XCTAssertEqual(fdFlagOpen, 0)
        } else {
            XCTFail("Failed to create socket")
        }
        
        // release socket
        optionalSocket = nil
        
        // file descriptor should be closed
        let fdFlagClosed = fcntl(descriptor, F_GETFD)
        XCTAssertEqual(fdFlagClosed, -1)
    }
    
    func testReleasingUDPInternetSocket() throws {
        var optionalSocket:UDPInternetSocket? = try UDPInternetSocket(address: .localhost(port: 0))
        
        guard let descriptor = optionalSocket?.descriptor else {
            XCTFail("Failed to get descriptor")
            return
        }

        if let socket = optionalSocket {
            // file descriptor should be open
            let fdFlagOpen = fcntl(socket.descriptor, F_GETFD)
            XCTAssertEqual(fdFlagOpen, 0)
        } else {
            XCTFail("Failed to create socket")
        }
        
        // release socket
        optionalSocket = nil
        
        // file descriptor should be closed
        let fdFlagClosed = fcntl(descriptor, F_GETFD)
        XCTAssertEqual(fdFlagClosed, -1)
    }
}
