
import Socks

let client = try! TCPClient(hostname: "google.com", port: 80)
try! client.write(data: "GET /\r\n\r\n")
//let client = try! TCPClient(hostname: "localhost", port: 8080)
//try! client.write("hello world!")
let str = try! client.readAll().toString()
try! client.close()

print("Received: \n\(str)")
