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
    
    func recv(maxBytes: Int = BufferCapacity) throws -> [UInt8] {
        
        let data = Bytes(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let receivedBytes = socket_recv(self.rawSocket.descriptor, data.rawBytes, data.capacity, flags)
        guard receivedBytes > -1 else { throw Error(.ReadFailed) }
        let finalBytes = data.characters[0..<receivedBytes]
        let out = Array(finalBytes.map({ UInt8($0) }))
        return out
    }
    
    func send(data: [UInt8]) throws {
        
        let len = data.count
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let sentLen = socket_send(self.rawSocket.descriptor, data, len, flags)
        guard sentLen == len else { throw Error(.SendFailedToSendAllBytes) }
    }
}

extension InternetSocket : ClientSocket {
    
    func connect() throws {
        
        var addr = try self.address.toCType()
        let res = socket_connect(self.rawSocket.descriptor, &addr, socklen_t(sizeof(sockaddr)))
        guard res > -1 else { throw Error(.ConnectFailed) }
    }
}

