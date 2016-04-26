
import Socks
import SocksCore    // needed for InternetAddress ... 

let internetAddress = InternetAddress(hostname: "google.com", port: .Portnumber(80))
let client = try! TCPClient(internetAddress : internetAddress)
try! client.write(data: "GET /\r\n\r\n")
let str = try! client.readAll().toString()
try! client.close()

print("Received: \n\(str)")
