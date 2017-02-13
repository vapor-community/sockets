import XCTest
@testable import SocksCore

#if os(Linux)
    import Glibc
    private let F_GETFD = Glibc.F_GETFD
#endif


class LifetimeTests: XCTestCase {

    func testStoppingAClosedTCPInternetSocket() throws {
        let socket = try TCPInternetSocket(address: .localhost(port: 0))

        #if os(Linux)
           let _ = Glibc.close(socket.descriptor)
        #else
           let _ =  Darwin.close(socket.descriptor)
        #endif

        XCTAssertThrowsError(try socket.close())
    }

    func testStoppingTCPInternetSocket() throws {
        let socket = try TCPInternetSocket(address: .localhost(port: 0))

        // file descriptor should be open
        let fdFlagOpen = fcntl(socket.descriptor, F_GETFD)
        XCTAssertEqual(fdFlagOpen, 0)
        
        try socket.close()

        XCTAssertTrue(socket.closed)
        
        // file descriptor should be closed
        let fdFlagClosed = fcntl(socket.descriptor, F_GETFD)
        XCTAssertEqual(fdFlagClosed, -1)
        
        // attempt to close a second again; shouldn't throw
        try socket.close()

        do {
            // attempt to listen should fail on a closed socket
            _ = try socket.listen()
        }
        catch let error as SocksError {
            guard case ErrorReason.socketIsClosed = error.type else {
                XCTFail("Wrong error")
                return
            }
        }
        catch {
            XCTFail("Wrong error")
        }
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
        
        do {
            // attempt to receive should fail on a closed socket
            _ = try socket.recvfrom()
        }
        catch let error as SocksError {
            guard case ErrorReason.socketIsClosed = error.type else {
                XCTFail("Wrong error")
                return
            }
        }
        catch {
            XCTFail("Wrong error")
        }
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
