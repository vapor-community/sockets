import libc
import Transport

public protocol RawSocket: Transport.Stream {
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
