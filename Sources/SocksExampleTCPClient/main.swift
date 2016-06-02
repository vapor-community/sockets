
import Socks

let address = InternetAddress(hostname: "google.com", port: .portNumber(80))
//let address = InternetAddress(hostname: "216.58.208.46", port: .portNumber(80))
// let address = InternetAddress.localhost(port: 8080)
//let address = InternetAddress(hostname: "192.168.1.170", port: .portNumber(2425))
let client = try! TCPClient(address: address)
try! client.send(bytes: "GET /\r\n\r\n".toBytes())
let str = try! client.receiveAll().toString()
try! client.close()

print("Received: \n\(str)")
