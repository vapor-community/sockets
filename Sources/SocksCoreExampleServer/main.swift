
import SocksCore
/*
let raw = try! RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
let addr = InternetAddress(address: .Hostname("localhost"), port: 8080)
let socket: ServerSocket = InternetSocket(rawSocket: raw, address: addr)

try! socket.bind()
try! socket.listen(4096)

print("Listening on \(addr)")

while true {
    let client = try! socket.accept()
    
    //read, echo back, close
    let data = try! client.recv()
    try! client.send(data)
    try! client.close()
    print("Echoed: \(try! data.toString())")
}
*/

let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)

let userProvidedInternetAddress = KclInternetAddress(hostname : "localhost", port : .Portnumber(8080))

let socket = try! KclInternetSocket(socketConfig: socket_Config, address: userProvidedInternetAddress)

try! socket.bind()
try! socket.listen(4096)

print("Listening on \(userProvidedInternetAddress.hostname) port \(userProvidedInternetAddress.port)")

while true {
    let client = try! socket.accept()
    
    //read, echo back, close
    let data = try! client.recv()
    try! client.send(data)
    try! client.close()
    print("Echoed: \(try! data.toString())")
}
