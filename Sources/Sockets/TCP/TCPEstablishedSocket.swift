public class TCPEstablishedSocket: TCPSocket {
    public let isClosed = false
    public let descriptor: Descriptor

    public init(descriptor: Descriptor) {
        self.descriptor = descriptor
    }
}

extension TCPEstablishedSocket: TCPWriteableSocket { }
extension TCPEstablishedSocket: TCPReadableSocket { }
