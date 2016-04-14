
import Socks

let port = 8080
let server = try! SynchronousTCPServer(hostname: "localhost", port: port)
print("Listening on port \(port)")
try! server.startWithHandler { (connection: Actor) in
    //echo
    let data = try connection.readAll()
    try connection.write(data: data)
    try connection.close()
    print("Echoed: \(try data.toString())")
}
