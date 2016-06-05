
import Socks

//let address = InternetAddress(hostname: "google.com", port: .portNumber(80))
let address = InternetAddress(hostname: "localhost", port: .portNumber(8080))
let client = try! UDPClient(address: address)
try! client.send(bytes: "Hello Socks world!\n\r".toBytes())
let (data, sender) = try! client.receive()

let str = try! data.toString()
let senderStr = String(sender)
print("Received: \n\(str) from \(senderStr)")
