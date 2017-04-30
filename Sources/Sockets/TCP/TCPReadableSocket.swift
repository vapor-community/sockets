import libc

public protocol TCPReadableSocket: TCPSocket, ReadableStream {}

extension TCPReadableSocket {
    public func read(max: Int, into buffer: inout Bytes) throws -> Int {
        let receivedBytes = libc.recv(
            descriptor.raw,
            &buffer,
            max,
            0
        )

        guard receivedBytes != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try read(max: max, into: &buffer)
            case ECONNRESET:
                // closed by peer, need to close this side.
                // Since this is not an error, no need to throw unless the close
                // itself throws an error.
                _ = try self.close()
                return 0
            default:
                throw SocketsError(.readFailed)
            }
        }

        guard receivedBytes > 0 else {
            // receiving 0 indicates a proper close .. no error.
            // attempt a close, no failure possible because throw indicates already closed
            // if already closed, no issue.
            // do NOT propogate as error
            _ = try? self.close()
            return 0
        }

        return receivedBytes
    }
}
