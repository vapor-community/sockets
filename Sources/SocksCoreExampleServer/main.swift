
import SocksCore

let raw = try! RawSocket(protocolFamily: .Inet, socketType: .Stream, protocol: .TCP)
let addr = InternetAddress(address: .Hostname("localhost"), port: 8080)
let socket = InternetSocket(rawSocket: raw, address: addr)

try! socket.bind()
try! socket.listen()

print("Listening on \(addr)")

while true {
    let client = try! socket.accept()
    
    //read, echo back, close
    let data = try! client.recv()
    try! client.send(data: data)
    try! client.close()
    print("Echoed: \(try! data.toString())")
}

