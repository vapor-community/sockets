//
//  Socket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_close = Glibc.close
#else
    import Darwin
    private let socket_close = Darwin.close
#endif

protocol Socket {
    func send() throws
    func recv() throws
    func close() throws
}

protocol ClientSocket: Socket {
    func connect() throws
}

protocol ServerSocket: Socket {
    //TODO
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
    
    func close() throws {
        if socket_close(self.descriptor) != 0 {
            throw Error(.CloseSocketFailed)
        }
    }
    
    deinit {
        _ = try? close()
    }
}





