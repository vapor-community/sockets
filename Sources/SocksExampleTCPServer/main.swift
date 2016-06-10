
import Socks

do {
    let server = try SynchronousTCPServer(port: 8080)
    print("Listening on \"\(server.address.hostname)\" (\(server.address.addressFamily)) \(server.address.port)")
    
    try server.startWithHandler { (client) in
        //echo
        let data = try client.receiveAll()
        try client.send(bytes: data)
        try client.close()
        print("Echoed: \(try data.toString())")
    }
} catch {
    print("Error \(error)")
}
