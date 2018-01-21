import Async
import Bits
import Dispatch
import TCP
import XCTest

let _data = """
HTTP/1.1 200 OK\r
Content-Length: 0\r
\r

""".data(using: .utf8)!

class SocketsTests: XCTestCase {
    func testServer() {
        do {
            try _testServer()
        } catch {
            XCTFail("\(error)")
        }
    }
    func _testServer() throws {
        let serverSocket = try TCPSocket(isNonBlocking: true)
        let server = try TCPServer(socket: serverSocket)
        try server.start(port: 8338)

        for i in 1...4 {
            let workerLoop = try DefaultEventLoop(label: "codes.vapor.test.worker.\(i)")
            let serverStream = server.stream(on: workerLoop)

            /// set up the server stream
            serverStream.drain { client, done in
                let clientSource = client.socket.source(on: workerLoop)
                let clientSink = client.socket.sink(on: workerLoop)
                clientSource.map(to: ByteBuffer.self) { input in
                    // print(String(data: Data(input), encoding: .utf8)!)
                    return _data.withByteBuffer { $0 }
                }.output(to: clientSink)
                // clientSource.output(to: clientSink)
                done()
            }.catch { err in
                XCTFail("\(err)")
            }.finally {
                // server closed, should never happen
            }
            
            // beyblades let 'er rip
            Thread.async { workerLoop.runLoop() }
        }

        let group = DispatchGroup()
        group.enter()
        group.wait()

        let exp = expectation(description: "all requests complete")
        var num = 1024
        for _ in 0..<num {
            let clientSocket = try TCPSocket(isNonBlocking: false)
            let client = try TCPClient(socket: clientSocket)
            try client.connect(hostname: "localhost", port: 8338)
            let write = Data("hello".utf8)
            _ = try client.socket.write(write)
            let read = try client.socket.read(max: 512)
            client.close()
            XCTAssertEqual(read, write)
            num -= 1
            if num == 0 {
                exp.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
        server.stop()
    }
    
    func testMultipleTCPSocketClose() throws {
        let socket = try TCPSocket(isNonBlocking: false, shouldReuseAddress: false)
        let socketDescriptor = socket.descriptor
        let nullHandle = FileHandle.standardError
        let nullDescriptor = nullHandle.fileDescriptor
        
        // This test is a bit tricky. It's necessary to set up a situation where
        // a given descriptor will be reassigned to a different object after the
        // TCPSocket is done with it. The easiest way to do this is to force the
        // issue with dup2().
        
        // Check that the socket was, in fact, open and then closed.
        XCTAssertNotEqual(fcntl(socketDescriptor, F_GETFL), -1)
        socket.close()
        XCTAssertEqual(fcntl(socketDescriptor, F_GETFL), -1)
        XCTAssertEqual(errno, EBADF)
        
        // Duplicate another descriptor to the closed one's value and check that
        // it is now a valid descriptor.
        XCTAssertEqual(dup2(nullDescriptor, socketDescriptor), socketDescriptor)
        XCTAssertNotEqual(fcntl(socketDescriptor, F_GETFL), -1)
        
        // Try closing the socket a second time and check that the reassigned
        // descriptor is still valid.
        socket.close()
        XCTAssertNotEqual(fcntl(socketDescriptor, F_GETFL), -1)
    }

    static let allTests = [
        ("testServer", testServer),
        ("testMultipleTCPSocketClose", testMultipleTCPSocketClose),
    ]
}
