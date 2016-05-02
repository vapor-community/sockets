
import Socks
import SocksCore    

//let address = InternetAddress(hostname: "google.com", port: .PortNumber(80))
let address = InternetAddress(hostname: "localhost", port: .PortNumber(8080))
let client = try! UDPClient(internetAddress: address)
try! client.write(data: "GET /\r\n\r\n")
let str = try! client.readAll().toString()
try! client.close()

print("Received: \n\(str)")
