
import Socks
import SocksCore    // needed for Internet_Address ... 

let internetAddress = Internet_Address(hostname: "google.com", port: .Portnumber(80))
let client = try! TCPClient(internetAddress : internetAddress)
try! client.write(data: "GET /\r\n\r\n")
let str = try! client.readAll().toString()
try! client.close()

print("Received: \n\(str)")
