public protocol WriteableStream: Stream {
    func write(max: Int, from buffer: Bytes) throws -> Int
}


extension WriteableStream {
    public func write(_ bytes: Bytes) throws -> Int {
        return try write(max: bytes.count, from: bytes)
    }
    
    public func write(_ byte: Byte) throws -> Int {
        return try write(max: 1, from: [byte])
    }

    public func write(_ string: BytesConvertible) throws -> Int {
        return try write(try string.makeBytes())
    }

    /// Writes a CRLF line ending
    public func writeLineEnd() throws -> Int {
        return try write([.carriageReturn, .newLine])
    }
}
