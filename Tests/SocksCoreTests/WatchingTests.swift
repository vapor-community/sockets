import XCTest
import Dispatch
@testable import SocksCore

class WatchingTests: XCTestCase {
    
    func testWatching() throws {
        
        let serverAddress = InternetAddress.localhost(port: 0)
        let serverSocket = try TCPInternetSocket(address: serverAddress)
        try serverSocket.bind()
        try serverSocket.listen(queueLimit: 4096)
        
        let queue = DispatchQueue(label: "codes.vapor.watchingTest", qos: .background)
        let group = DispatchGroup()
        
        group.enter()
        try serverSocket.startWatching(on: queue) {
            group.leave()
        }
        
        let automaticallyAssignedServerAddress = try serverSocket.localAddress()
        let connectToAddress = InternetAddress.localhost(port: automaticallyAssignedServerAddress.port)

        let clientSocket = try TCPInternetSocket(address: connectToAddress)
        try clientSocket.connect()
        
        let timeout:Double = 1
        let result = group.wait(timeout: .now() + timeout)
        guard result == DispatchTimeoutResult.success else {
            XCTFail("Test timed out after \(timeout) seconds")
            return
        }
        
        serverSocket.stopWatching()
    }
}
