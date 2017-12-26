import libc

public protocol TCPWriteableSocket: TCPSocket, WriteableStream { }

extension TCPWriteableSocket {
    public func write(max: Int, from buffer: Bytes) throws -> Int {
        guard !isClosed else {
            throw SocketsError(.socketIsClosed)
        }
        
        let bytesWritten = libc.send(descriptor.raw, buffer, max, 0)
        
        guard bytesWritten != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try write(max: max, from: buffer)
            case ECONNRESET:
                // closed by peer, need to close this side.
                // Since this is not an error, no need to throw unless the close
                // itself throws an error.
                _ = try self.close()
                return 0
            default:
                throw SocketsError(.writeFailed)
            }
        }
        
        return bytesWritten
    }

    public func flush() throws {
        // no need to flush
    }
}
