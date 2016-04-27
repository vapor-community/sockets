
import SocksCore

let socket_Config = SocketConfig.TCP()

let userProvidedInternetAddress = InternetAddress(hostname : "localhost", port : .PortNumber(8080))

let socket = try! InternetSocket(socketConfig: socket_Config, address: userProvidedInternetAddress)

try! socket.bind()
try! socket.listen()

print("Listening on \(userProvidedInternetAddress.hostname) port \(userProvidedInternetAddress.port)")

while true {
    let client = try! socket.accept()
    
    //read, echo back, close
    let data = try! client.recv()
    try! client.send(data: data)
    try! client.close()
    print("Echoed: \(try! data.toString())")
}
