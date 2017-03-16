import libc

public protocol TCPClient: TCPSocket, InternetSocket, ClientStream {}

extension TCPClient {
    public func connect() throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        let res = libc.connect(descriptor.raw, address.raw, address.rawLen)
        guard res > -1 else { throw SocksError(.connectFailed) }
        try securityLayer.connect(self)
    }
}
