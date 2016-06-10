
import Socks

//let address = InternetAddress(hostname: "google.com", port: .portNumber(80))
let address = InternetAddress.localhost(port: 8080)

do {
    let client = try UDPClient(address: address)
    try client.send(bytes: "Hello Socks world!\n\r".toBytes())
    let (data, sender) = try client.receive()
    try client.close()
    
    let str = try data.toString()
    let senderStr = String(sender)
    print("Received: \n\(str) from \(senderStr)")
} catch {
    print("Error \(error)")
}
