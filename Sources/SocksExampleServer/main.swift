
import Socks
import SocksCore

let internetAddress = InternetAddress(hostname: "localhost", port: .Portnumber(8080))
let server = try! SynchronousTCPServer(internetAddress : internetAddress)
print("Listening on port \(internetAddress.port)")
try! server.startWithHandler { (connection: Actor) in
    //echo
    let data = try connection.readAll()
    try connection.write(data: data)
    try connection.close()
    print("Echoed: \(try data.toString())")
}
