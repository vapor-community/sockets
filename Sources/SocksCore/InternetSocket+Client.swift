//
//  InternetSocket+Client.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_connect = Glibc.connect
#else
    import Darwin
    private let socket_connect = Darwin.connect
#endif

extension InternetSocket : ClientSocket {
    
    public func connect() throws {
        
        var addr = try self.address.toCType()
        let res = socket_connect(self.descriptor, &addr, socklen_t(sizeof(sockaddr)))
        guard res > -1 else { throw Error(.ConnectFailed) }
        
        //socket_connect(self.descriptor, address.ai_sockadr, address.ai_addrlen)
    }
}

extension KclInternetSocket : ClientSocket {
    
    public func connect() throws {
        let res = socket_connect(self.descriptor, address.resolvedCTypeAddress.ai_addr, address.resolvedCTypeAddress.ai_addrlen)
        guard res > -1 else { throw Error(.ConnectFailed)}
    }
}