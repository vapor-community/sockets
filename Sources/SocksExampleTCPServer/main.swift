
import Socks

let server = try! SynchronousTCPServer(port: 8080)
print("Listening on port \(server.address.port)")
try! server.startWithHandler { (client) in
    //echo
    let data = try client.receiveAll()
    try client.send(bytes: data)
    try client.close()
    print("Echoed: \(try data.toString())")
}
