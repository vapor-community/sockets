import libc

public protocol TCPServer: TCPSocket, InternetSocket, ServerStream { }

extension TCPServer {
    public func listen(queueLimit: Int32 = 4096) throws {
        if isClosed { throw SocketsError(.socketIsClosed) }
        let res = libc.listen(descriptor.raw, queueLimit)
        guard res > -1 else { throw SocketsError(.listenFailed) }
    }

    public func accept() throws -> DuplexStream {
        if isClosed { throw SocketsError(.socketIsClosed) }
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        let clientSocketDescriptor = libc.accept(descriptor.raw, addrSockAddr, &length)

        guard clientSocketDescriptor > -1 else {
            addr.deallocate(capacity: 1)
            if errno == SocketsError.interruptedSystemCall {
                return try accept()
            }
            throw SocketsError(.acceptFailed)
        }

        let clientAddress = ResolvedInternetAddress(raw: addr)
        let clientSocket = try TCPInternetSocket(
            Descriptor(clientSocketDescriptor),
            config,
            clientAddress,
            self.securityLayer
        )

        return try securityLayer
            .accept(clientSocket)
    }
}
