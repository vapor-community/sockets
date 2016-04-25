
import SocksCore

let socket_Config = SocketConfig(addressFamily: .UNSPECIFIED, socketType: .Stream, protocolType: .TCP)

let userProvidedInternetAddress = Internet_Address(hostname : "localhost", port : .Portnumber(8080))

let socket = try! InternetSocket(socketConfig: socket_Config, address: userProvidedInternetAddress)

try! socket.bind()
try! socket.listen(queueLimit: 4096)

print("Listening on \(userProvidedInternetAddress.hostname) port \(userProvidedInternetAddress.port)")

while true {
    let client = try! socket.accept()
    
    //read, echo back, close
    let data = try! client.recv()
    try! client.send(data: data)
    try! client.close()
    print("Echoed: \(try! data.toString())")
}
