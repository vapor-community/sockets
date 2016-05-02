
import Socks
import SocksCore

let address = InternetAddress(hostname: "localhost", port: .PortNumber(8080))
let server = try! SynchronousUDPServer(internetAddress: address)
print("Listening on port \(address.port)")
try! server.startWithHandler { (connection: Actor) in
    //echo
    let data = try connection.readAll()
    try connection.write(data: data)
    try connection.close()
    print("Echoed: \(try data.toString())")
}
