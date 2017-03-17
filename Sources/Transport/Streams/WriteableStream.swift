public protocol WriteableStream: Stream {
    func write(_ bytes: Bytes) throws
    func flush() throws
}


extension WriteableStream {
    /// Sometimes we let sockets queue things up before flushing, but in situations like web sockets,
    /// we may want to skip that functionality
    public func write(_ bytes: Bytes, flushing: Bool) throws {
        try write(bytes)
        if flushing {
            try flush()
        }
    }

    public func write(_ byte: Byte) throws {
        try write([byte])
    }

    public func write(_ string: BytesConvertible) throws {
        try write(try string.makeBytes())
    }

    /// Writes a CRLF line ending
    public func writeLineEnd() throws {
        try write([.carriageReturn, .newLine])
    }
}
