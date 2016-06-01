
import Socks

let address = InternetAddress(hostname: "google.com", port: .portNumber(80))
let client = try! TCPClient(address: address)
try! client.send(bytes: "GET /\r\n\r\n".toBytes())
let str = try! client.receiveAll().toString()
try! client.close()

print("Received: \n\(str)")
