//
//  InternetSocket+Server.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_bind = Glibc.bind
    private let socket_listen = Glibc.listen
    private let socket_accept = Glibc.accept
#else
    import Darwin
    private let socket_bind = Darwin.bind
    private let socket_listen = Darwin.listen
    private let socket_accept = Darwin.accept
#endif

extension InternetSocket : ServerSocket {
    
    public func bind() throws {
        
        var addr = try self.address.toCType()
        let res = socket_bind(self.descriptor, &addr, socklen_t(sizeof(sockaddr)))
        guard res > -1 else { throw Error(.BindFailed) }
    }
    
    public func listen(queueLimit: Int32 = 4096) throws {
        
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw Error(.ListenFailed) }
    }
    
    public func accept() throws -> Socket {
        
        var addr = sockaddr()
        var len = socklen_t()
        let clientSocketDescriptor = socket_accept(self.descriptor, &addr, &len)
        guard clientSocketDescriptor > -1 else {
            throw Error(.AcceptFailed)
        }
        let clientSocket = try self.rawSocket.copyWithNewDescriptor(descriptor: clientSocketDescriptor)
        return clientSocket
    }
}




