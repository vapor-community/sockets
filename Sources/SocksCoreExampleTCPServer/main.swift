
import SocksCore

let address = InternetAddress(hostname : "localhost", port : .portNumber(8080))
let socket = try! InternetSocket(socketConfig: .TCP(), address: address)

try! socket.bind()
try! socket.listen()

print("Listening on \(address.hostname) port \(address.port)")

while true {
    
    //block until a connection is made by a client
    let client = try! socket.accept()
    
    //read, echo back, close
    let data = try! client.recv()
    try! client.send(data: data)
    try! client.close()
    print("Echoed: \(try! data.toString())")
}
