import Async
import Bits
import Foundation

extension TCPSocket {
    /// Copies bytes into a buffer and writes them to the socket.
    public func write(_ data: Data) throws -> TCPSocketStatus {
        return try data.withByteBuffer { buffer in
            return try write(from: buffer)
        }
    }

    /// Reads bytes and copies them into a Data struct.
    public func read(max: Int) throws -> Data {
        var data = Data(repeating: 0, count: max)

        let read = try data.withUnsafeMutableBytes { (pointer: MutableBytesPointer) -> TCPSocketStatus in
            let buffer = MutableByteBuffer(start: pointer, count: max)
            return try self.read(into: buffer)
        }

        switch read {
        case .success(let count): data.removeLast(data.count &- count)
        case .wouldBlock:
            ERROR("TCPSocket blocked during read Data.")
            return data
        }

        return data
    }
}

