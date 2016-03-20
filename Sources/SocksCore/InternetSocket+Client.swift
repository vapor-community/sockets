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
    
    func connect() throws {
        
        var addr = try self.address.toCType()
        let res = socket_connect(self.descriptor, &addr, socklen_t(sizeof(sockaddr)))
        guard res > -1 else { throw Error(.ConnectFailed) }
    }
}
