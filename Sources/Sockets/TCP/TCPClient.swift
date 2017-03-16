import libc

public protocol TCPClient: TCPSocket, InternetSocket, ClientStream {}

extension TCPClient {
    public func connect() throws {
        if isClosed { throw SocketsError(.socketIsClosed) }
        let res = libc.connect(descriptor.raw, address.raw, address.rawLen)
        guard res > -1 else { throw SocketsError(.connectFailed) }
        try securityLayer.connect(self)
    }
}
