
import Socks

do {
    let server = try SynchronousUDPServer(port: 8080)
    print("Listening on port \(server.address.port)")
    try server.startWithHandler { (received, client) in
        print("Echoing \(try received.toString())")
        try client.send(bytes: received)
        try client.close()
    }
} catch {
    print("Error \(error)")
}

