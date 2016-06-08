import SocksCore
import Socks

enum MyError: ErrorProtocol {
    case descriptorReuse
}

enum HandleResult {
    case keepAlive
    case close
}

func handleMessage(client: TCPClient) throws -> HandleResult {
    //read, echo back, close
    let data = try client.receiveAll()
    guard data.count > 0 else {
        //end of stream, close self
        return .close
    }
    try client.send(bytes: data)
    print("Client: \(client.socket.address)")
    return .keepAlive
}

do {
    //let address = InternetAddress.any(port: 8080, ipVersion: .inet6)
    let address = InternetAddress.any(port: 8080)
    let server = try TCPInternetSocket(address: address)
    
    try server.bind()
    try server.listen()
    
    print("Listening on \"\(address.hostname)\" (\(address.addressFamily)) \(address.port)")

    var connections: [Descriptor: TCPClient] = [:]
    
    func closeClient(client: TCPClient) throws {
        print("Closing client: \(client.socket.address)")
        connections.removeValue(forKey: client.socket.descriptor)
        try client.close()
    }

    while true {
        
        print("Listening, number of connected clients: \(connections.count)")
        
        //Wait for data on either the server socket and connected clients
        let watchedReads = Array(connections.keys) + [server.descriptor]
        let (reads, writes, errors) = try select(reads: watchedReads, errors: watchedReads)
        
        //first handle any existing connections
        try reads
            .filter { $0 != server.descriptor }
            .forEach {
                let client = connections[$0]!
                do {
                    let result = try handleMessage(client: client)
                    switch result {
                    case .close:
                        try closeClient(client: client)
                    case .keepAlive:
                        break
                    }
                } catch {
                    print("Error: \(error)")
                    try closeClient(client: client)
                }
        }
        
        //then only continue if there's data on the server listening socket
        guard Set(reads).contains(server.descriptor) else { continue }
        
        // Accept a new connection and add it to our list
        let socket = try server.accept()
        socket.keepAlive = true
        let client = try TCPClient(alreadyConnectedSocket: socket)
        let descriptor = client.socket.descriptor
        guard connections[descriptor] == nil else {
            throw MyError.descriptorReuse
        }
        connections[descriptor] = client
    }
} catch {
    print("Error \(error)")
}
