import libc

public protocol Pipeable {
    static func pipe() throws -> (read: TCPReadableSocket, write: TCPWriteableSocket)
}

extension TCPEstablishedSocket: Pipeable {
    public static func pipe() throws -> (read: TCPReadableSocket, write: TCPWriteableSocket) {
        var rawDescriptors: [Int32] = [0, 0]
        let socketType = SocketType.stream.toCType()
        guard socketpair(AF_LOCAL, socketType, 0, &rawDescriptors) != -1 else {
            throw SocketsError(.pipeCreationFailed)
        }

        let descriptors = rawDescriptors.map({ Descriptor($0) })
        try descriptors.forEach({ try $0.disableSIGPIPE() })

        let read = TCPEstablishedSocket(descriptor: descriptors[0])
        let write = TCPEstablishedSocket(descriptor: descriptors[1])
        return (read, write)
    }
}
