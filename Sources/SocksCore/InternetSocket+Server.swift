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
        
        let addr = self.address.resolvedCTypeAddress
        let res = socket_bind(self.descriptor, addr.ai_addr, addr.ai_addrlen)
        guard res > -1 else { throw Error(.BindFailed) }
    }
    
    public func listen(queueLimit: Int32 = 4096) throws {
        
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw Error(.ListenFailed) }
    }
    
    public func accept() throws -> Socket {
        
        // the type of this variable is big enough to store a IPv6 (and of course a IPv4) address
        // that's important because we don't know upfront if a IPv6 or a IPv4 client wants to connect
        var clientAddress = UnsafeMutablePointer<sockaddr_storage>.init(nil)
        
        var length = socklen_t(sizeof(sockaddr_storage) )
        let clientSocketDescriptor = socket_accept(self.descriptor, sockaddr_storage_cast(p: clientAddress!),&length)
        
        guard clientSocketDescriptor > -1 else {
            throw Error(.AcceptFailed)
        }
        let clientSocket = try self.rawSocket.copyWithNewDescriptor(descriptor: clientSocketDescriptor)
        return clientSocket
    }
}
