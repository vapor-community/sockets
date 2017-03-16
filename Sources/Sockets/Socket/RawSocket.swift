import libc

public protocol RawSocket: Stream {
    var descriptor: Descriptor { get }
    var isClosed: Bool { get }
    func close() throws
}

extension RawSocket {
    public func close() throws {
        if libc.close(descriptor.raw) != 0 {
            throw SocketsError(.closeSocketFailed)
        }
    }
}
