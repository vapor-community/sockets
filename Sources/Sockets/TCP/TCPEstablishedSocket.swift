public class TCPEstablishedSocket: TCPSocket {
    public let isClosed = false
    public let descriptor: Descriptor

    public init(descriptor: Descriptor) {
        self.descriptor = descriptor
    }
}

public class TCPEstablishedWriteableSocket: TCPEstablishedSocket, TCPWriteableSocket { }
public class TCPEstablishedReadableSocket: TCPEstablishedSocket, TCPReadableSocket { }
