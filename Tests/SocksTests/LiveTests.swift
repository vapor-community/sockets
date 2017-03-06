import XCTest
@testable import Socks

class LiveTests: XCTestCase {

    func testLive_HTTP_Get_ipV4() throws {
        
        let addr = InternetAddress(hostname: "httpbin.org",
                                   port: 80)
        let socket = try TCPInternetSocket(address: addr)
        
        try socket.connect()
        
        try socket.send(data: "GET /\r\n\r\n".toBytes())
        
        //receiving data
        let received = try socket.recv()
        
        //converting data to a string
        let str = try received.toString()
        
        //yay!
        XCTAssertTrue(received.starts(with: "<!DOCTYPE html>".toBytes()), "Instead received: \(str)")
        
        try! socket.close()
        print("successfully sent and received data from httpbin.org")
    }
    
    func testLive_HTTP_Get_ipV4_withTimeout() throws {
        
        let addr = InternetAddress(hostname: "httpbin.org",
                                   port: 80)
        let socket = try TCPInternetSocket(address: addr)
        
        try socket.connect(withTimeout: 2)
            
        try socket.send(data: "GET /\r\n\r\n".toBytes())
        
        //receiving data
        let received = try socket.recv()
        
        //converting data to a string
        let str = try received.toString()
        
        //yay!
        XCTAssertTrue(received.starts(with: "<!DOCTYPE html>".toBytes()), "Instead received: \(str)")
        
        try socket.close()
        print("successfully sent and received data from google.com")
    }
}
