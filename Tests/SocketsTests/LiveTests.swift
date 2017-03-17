import XCTest
@testable import Sockets

class LiveTests: XCTestCase {

    func testLive_HTTP_Get_ipV4() throws {
        let addr = InternetAddress(
            hostname: "httpbin.org",
            port: 80
        )
        let socket = try TCPInternetSocket(addr)
        
        try socket.connect()
        
        try socket.write("GET / HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
        
        //receiving data
        let received = try socket.read(max: 2048)
        
        //converting data to a string
        let str = received.makeString()

        //yay!
        XCTAssertTrue(
            received
                .starts(with: "HTTP/1.1 200 OK".makeBytes()),
            "Instead received: \(str)"
        )
        
        try! socket.close()
    }
    
    func testLive_HTTP_Get_ipV4_withTimeout() throws {
        
        let addr = InternetAddress(hostname: "httpbin.org",
                                   port: 80)
        let socket = try TCPInternetSocket(addr)
        
        try socket.connect()
            
        try socket.write("GET / HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
        
        //receiving data
        let received = try socket.read(max: 2048)
        
        //converting data to a string
        let str = received.makeString()
        
        //yay!
        XCTAssertTrue(
            received.starts(with: "HTTP/1.1 200 OK".makeBytes()),
            "Instead received: \(str)"
        )
        
        try socket.close()
        print("successfully sent and received data from google.com")
    }
}
