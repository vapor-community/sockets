//
//  Socket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

protocol Socket {
    
}

class RawSocket {
    
    let descriptor: Descriptor
    
    init(protocolFamily: ProtocolFamily = .Inet, socketType: SocketType, protocol prot: Protocol) throws {
        
        let cProtocolFam = protocolFamily.toCType()
        let cType = socketType.toCType()
        let cProtocol = prot.toCType()
        
        let descriptor = socket(cProtocolFam, cType, cProtocol)
        guard descriptor > 0 else { throw Error(.CreateSocketFailed) }
        self.descriptor = descriptor
    }
    
    deinit {
        //FIXME: close can fail, how do we communicate that
        //when deinit cannot throw?
        close(self.descriptor)
    }
}

class InternetSocket: Socket {
    
    let rawSocket: RawSocket
    
    init(rawSocket: RawSocket) {
        self.rawSocket = rawSocket
    }
    
    
}




