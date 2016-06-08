import SocksCore

do {
    //let address = InternetAddress.any(port: 8080, ipVersion: .inet6)
    let address = InternetAddress.any(port: 8080)
    let socket = try TCPInternetSocket(address: address)
    
    try socket.bind()
    try socket.listen()
    
    print("Listening on \"\(address.hostname)\" (\(address.addressFamily)) \(address.port)")

    while true {
        
        //block until a connection is made by a client
        let client = try socket.accept()
        
        //read, echo back, close
        let data = try client.recv()
        try client.send(data: data)
        try client.close()
        print("Client: \(client.address), Echoed: \(try data.toString())")
    }
} catch {
    print("Error \(error)")
}