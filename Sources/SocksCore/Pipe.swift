#if os(Linux)
    import Glibc
    let socket_socketpair = Glibc.socketpair
#else
    import Darwin
    let socket_socketpair = Darwin.socketpair
#endif

public protocol Pipeable {
    static func pipe() throws -> (read: TCPReadableSocket, write: TCPWriteableSocket)
}

extension TCPEstablishedSocket: Pipeable {
    
    public static func pipe() throws -> (read: TCPReadableSocket, write: TCPWriteableSocket) {
        var descriptors: [Descriptor] = [0, 0]
        let socketType = SocketType.stream.toCType()
        guard socket_socketpair(AF_LOCAL, socketType, 0, &descriptors) != -1 else {
            throw SocksError(.pipeCreationFailed)
        }
        try descriptors.forEach {
            try TCPEstablishedSocket.disableSIGPIPE(descriptor: $0)
        }
        let read = TCPEstablishedReadableSocket(descriptor: descriptors[0])
        let write = TCPEstablishedWriteableSocket(descriptor: descriptors[1])
        return (read, write)
    }
}
