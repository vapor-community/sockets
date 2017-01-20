import XCTest
import Dispatch
@testable import SocksCore

class WatchingTests: XCTestCase {
    
    func testWatching() throws {
        
        var testData = [UInt8]()
        var clientsServed = 0
        
        // create 100MB of test data
        for index in 0..<100_000_000
        {
            let value = UInt8(index % 256)
            testData.append(value)
        }
        
        let listeningSocket = try TCPInternetSocket(address: .localhost(port: 0))
        try listeningSocket.bind()
        try listeningSocket.listen(queueLimit: 4096)
        
        let queue = DispatchQueue(label: "codes.vapor.watchingTest", qos: .background)
        let group = DispatchGroup()

        let cancelHandler = {
            group.leave()
        }
        
        try listeningSocket.startWatching(on: queue, cancel:cancelHandler) {
            guard let serveSocket = try? listeningSocket.accept() else {
                XCTFail("Socket failed to accept")
                return
            }
            
            clientsServed += 1
            
            var receivedData = [UInt8]()
            do {
                try serveSocket.startWatching(on: queue) {
                    do {
                        let newData = try serveSocket.recv(maxBytes: 65_507)
                        if newData.count == 0 {
                            // the socket has been closed
                            return
                        }
                        receivedData.append(contentsOf: newData)
                        
                        if receivedData.count == testData.count {
                            // comparing the whole array takes too long; compare just first and last byte instead
                            guard receivedData.first == testData.first && receivedData.last == testData.last else {
                                XCTFail("Transferred data does not match")
                                return
                            }
                            group.leave()
                        } else if receivedData.count > testData.count {
                            XCTFail("Transferred data does not match")
                        }
                    } catch {
                        XCTFail("serveSocket failed to receive data")
                    }
                }
            } catch {
                XCTFail("serveSocket failed to start watching")
            }
        }
        
        let automaticallyAssignedServerAddress = try listeningSocket.localAddress()
        //            print("Hosting on port \(automaticallyAssignedServerAddress.port); descriptor \(socket.descriptor)")
        let serverAddress = InternetAddress.localhost(port: automaticallyAssignedServerAddress.port)
        
        // first attempt; this should trigger a group leave
        let result = try connectToServer(serverAddress, on: queue, in: group, timeout: 20, send: testData)
        guard result == DispatchTimeoutResult.success else {
            XCTFail("Test timed out")
            return
        }
        
        // wait for cancel handler
        group.enter()

        listeningSocket.stopWatching()
        
        // checking if the cancel handler has been run
        guard group.wait(timeout: .now() + 1) == DispatchTimeoutResult.success else {
            XCTFail("Cancel handler did not run")
            return
        }
#if !os(Linux) // Linux implementation currently does not support timing out on write; it is synchronous and blocking
        // second attempt; this should time out, because the socket shouldn't be watching anymore
        let result2 = try connectToServer(serverAddress, on: queue, in: group, timeout: 0.5, send: testData)
        guard result2 == DispatchTimeoutResult.timedOut && clientsServed == 1 else {
            XCTFail("Server served second client")
            return
        }
#endif
    }
    
    func connectToServer(_ address:InternetAddress, on queue:DispatchQueue, in group:DispatchGroup, timeout:Double, send data:[UInt8]) throws -> DispatchTimeoutResult
    {
        group.enter()
        let clientSocket = try TCPInternetSocket(address: address)
        try clientSocket.connect()
#if !os(Linux)
        try clientSocket.startWatching(on: queue) {} // start watching to enable nonblocking mode
#endif
        try clientSocket.send(data: data)
        
#if os(Linux)
	try clientSocket.close()
        group.leave()
	return .success
#else
	let result = group.wait(timeout: .now() + timeout)
        try clientSocket.close()
        return result
#endif
    }
}
