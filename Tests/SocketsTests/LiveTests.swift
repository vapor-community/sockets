import Bits
import Sockets
import XCTest

class LiveTests: XCTestCase {

    func testLive_HTTP_Get_ipV4() throws {
        let addr = InternetAddress(
            hostname: "httpbin.org",
            port: 80
        )
        let socket = try TCPInternetSocket(addr)
        
        try socket.connect()
        
        _ = try socket.write("GET / HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
        
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
            
        _ = try socket.write("GET / HTTP/1.1\r\nHost: httpbin.org\r\n\r\n".makeBytes())
        
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
    
    func testBigBody() throws {
        do {
            let httpbin = try TCPInternetSocket(scheme: "http", hostname: "httpbin.org", port: 80)
            try httpbin.connect()
            
            _ = try httpbin.write("GET /bytes/8191 HTTP/1.1")
            _ = try httpbin.writeLineEnd()
            _ = try httpbin.write("Host: httpbin.org")
            _ = try httpbin.writeLineEnd()
            _ = try httpbin.writeLineEnd()

            var bytes: Bytes = []
            while true {
                let new = try httpbin.read(max: 1)
                if new.count == 0 {
                    break
                }
                if bytes.count > 8192 {
                    break
                }
                bytes += new
            }
            
            try httpbin.close()
            XCTAssert(bytes.count > 8192)
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testTooManyFilesOpen() throws {
        do {
            for _ in 0..<20 {
                let socket = try TCPInternetSocket(scheme: "http", hostname: "httpbin.org", port: 80)
                try socket.connect()
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}
