
import SocksCore

let address = InternetAddress(hostname: "google.com", port: 80)
// let address = InternetAddress.localhost(port: 8080)
//let address = InternetAddress.localhost(port: 8080, ipVersion: .inet6)
//let address = InternetAddress(hostname: "216.58.214.206", port: 80)

do {
    let socket = try TCPInternetSocket(address: address)
    try socket.connect()
    
    //sends a GET / request to google.com at port 80, expects a 302 redirect to HTTPS
    try socket.send(data: "GET /\r\n\r\n".toBytes())
    
    //receiving a chunk of data (might not be all)
    let received = try socket.recv()
    
    //converting data to a string
    let str = try received.toString()
    
    //yay!
    print("Received: \n\(str)")
    
    try socket.close()
    
    print("successfully sent and received data from \(address.hostname)")
} catch {
    print("Error: \(error)")
}


