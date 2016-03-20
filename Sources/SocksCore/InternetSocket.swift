//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_connect = Glibc.connect
    private let socket_recv = Glibc.recv
    private let socket_send = Glibc.send
#else
    import Darwin
    private let socket_connect = Darwin.connect
    private let socket_recv = Darwin.recv
    private let socket_send = Darwin.send
#endif

class InternetSocket {
    
    let rawSocket: RawSocket
    let address: InternetAddress
    
    init(rawSocket: RawSocket, address: InternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
}

extension InternetSocket : Socket {
    
    func close() throws {
        try self.rawSocket.close()
    }
    
    func recv() throws {
        
    }
    
    func send() throws {
        
    }
}

extension InternetSocket : ClientSocket {
    
    func connect() throws {
        
        var addr = try self.address.toCType()
        let res = socket_connect(self.rawSocket.descriptor, &addr, socklen_t(sizeof(sockaddr)))
        guard res > -1 else { throw Error(.ConnectFailed) }
    }
}

