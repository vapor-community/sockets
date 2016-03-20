//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

class InternetSocket: Socket {
    
    let rawSocket: RawSocket
    let address: InternetAddress
    
    var descriptor: Descriptor {
        return self.rawSocket.descriptor
    }
    
    init(rawSocket: RawSocket, address: InternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
    
    func close() throws {
        try self.rawSocket.close()
    }
}


