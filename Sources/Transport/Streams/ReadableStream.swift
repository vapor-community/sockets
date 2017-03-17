/// A readable byte stream
public protocol ReadableStream: Stream {
    func read(max: Int) throws -> Bytes
    // Optional, performance
    func readByte() throws -> Byte?
}

extension ReadableStream {
    /// Reads and filters non-valid ASCII characters
    /// from the stream until a new line character is returned.
    public func readLine() throws -> Bytes {
        var line: Bytes = []

        var lastByte: Byte? = nil

        while let byte = try readByte() {
            // Continues until a `crlf` sequence is found
            if byte == .newLine && lastByte == .carriageReturn {
                break
            }

            // Skip over any non-valid ASCII characters
            if byte > .carriageReturn {
                line += byte
            }

            lastByte = byte
        }

        return line
    }

    /// Reads all bytes from the stream using
    /// a chunk size.
    public func readAll(chunkSize: Int = 512) throws -> Bytes {
        var lastSize = 0
        var bytes: Bytes = []

        while lastSize < chunkSize {
            let chunk = try read(max: chunkSize)
            bytes += chunk
            lastSize = chunk.count
        }

        return bytes
    }

    /// Default implementation of receive grabs a one
    /// byte array from the stream and returns the first.
    ///
    /// This can be overridden with something more performant.
    public func readByte() throws -> Byte? {
        return try read(max: 1).first
    }
}
