import libc

public protocol TCPReadableSocket: TCPSocket, ReadableStream {}

extension TCPReadableSocket {
    public func read(max: Int) throws -> Bytes{
        let buffer = Buffer(capacity: max)

        let receivedBytes = libc.recv(
            descriptor.raw,
            buffer.pointer,
            buffer.capacity,
            0
        )

        guard receivedBytes != -1 else {
            if errno == ECONNRESET {
                // closed by peer, need to close this side.
                // Since this is not an error, no need to throw unless the close
                // itself throws an error.
                _ = try self.close()
                return []
            } else {
                throw SocketsError(.readFailed)
            }
        }

        guard receivedBytes > 0 else {
            // receiving 0 indicates a proper close .. no error.
            // attempt a close, no failure possible because throw indicates already closed
            // if already closed, no issue.
            // do NOT propogate as error
            _ = try? self.close()
            return []
        }

        return Array(buffer.bytes[0..<receivedBytes])
    }
}
