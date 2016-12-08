import XCTest
import Dispatch
@testable import SocksCore

class WatchingTests: XCTestCase {
    
    func testWatching() throws {
        
        let testData:[UInt8] = [1,2,3]
        
        let serverAddress = InternetAddress.localhost(port: 0)
        var serverSocket:TCPInternetSocket? = try TCPInternetSocket(address: serverAddress)
        if let socket = serverSocket {
            try socket.bind()
            try socket.listen(queueLimit: 4096)
            
            let queue = DispatchQueue(label: "codes.vapor.watchingTest", qos: .background)
            let group = DispatchGroup()
            
            try socket.startWatching(on: queue) {
                guard let clientSocket = try? socket.accept() else {
                    XCTFail("Socket failed to accept")
                    return
                }
                
                do {
                    try clientSocket.startWatching(on: queue) {
                        do {
                            let data = try clientSocket.recv(maxBytes: 65_507)
                            // ignore all socket events except those with data
                            guard data.count > 0 else { return }
                            if data == testData {
                                group.leave()
                            }
                        } catch {
                            XCTFail("Client socket failed to receive data")
                        }
                    }
                } catch {
                    XCTFail("Client socket failed to start watching")
                }
            }
            
            let automaticallyAssignedServerAddress = try socket.localAddress()
//            print("Hosting on port \(automaticallyAssignedServerAddress.port); descriptor \(socket.descriptor)")
            let serverAddress = InternetAddress.localhost(port: automaticallyAssignedServerAddress.port)
            
            // first attempt; this should trigger a group leave
            let result = try connectToServer(serverAddress, on: queue, in: group, timeout: 1, send: testData)
            guard result == DispatchTimeoutResult.success else {
                XCTFail("Test timed out")
                return
            }

            socket.stopWatching()

            // second attempt; this should time out, because the socket shouldn't be watching anymore
            let result2 = try connectToServer(serverAddress, on: queue, in: group, timeout: 0.1, send: testData)
            guard result2 == DispatchTimeoutResult.timedOut else {
                XCTFail("Test should have timed out")
                return
            }
        }
        
        serverSocket = nil
    }
    
    func connectToServer(_ address:InternetAddress, on queue:DispatchQueue, in group:DispatchGroup, timeout:Double, send data:[UInt8]) throws -> DispatchTimeoutResult
    {
        group.enter()
        let clientSocket = try TCPInternetSocket(address: address)
        try clientSocket.connect()
        try clientSocket.send(data: data)
        
        let result = group.wait(timeout: .now() + timeout)
        try clientSocket.close()

        return result
    }
}
