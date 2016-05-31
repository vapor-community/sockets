
import Socks
import SocksCore    

let address = InternetAddress(hostname: "google.com", port: .portNumber(80))
let client = try! TCPClient(internetAddress: address)
try! client.write(data: "GET /\r\n\r\n")
let str = try! client.readAll().toString()
try! client.close()

print("Received: \n\(str)")
