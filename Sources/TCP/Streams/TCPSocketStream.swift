import Async

/// An async `UnsafeBufferPointer<UInt8>` stream wrapper for `TCPSocket`.
public final class TCPSocketStream: Stream {
    /// See `InputStream.Input`
    public typealias Input = UnsafeBufferPointer<UInt8>

    /// See `OutputStream.Output`
    public typealias Output = UnsafeBufferPointer<UInt8>

    /// Internal socket source stream.
    internal let source: TCPSocketSource

    /// Internal socket sink stream.
    internal let sink: TCPSocketSink

    /// Internal stream init. Use socket convenience method.
    internal init(socket: TCPSocket, bufferSize: Int, on worker: Worker) {
        self.source = socket.source(on: worker, bufferSize: bufferSize)
        self.sink = socket.sink(on: worker)
    }

    /// See `InputStream.input(_:)`
    public func input(_ event: InputEvent<UnsafeBufferPointer<UInt8>>) {
        sink.input(event)
    }

    /// See `OutputStream.input(_:)`
    public func output<S>(to inputStream: S) where S : InputStream, TCPSocketStream.Output == S.Input {
        source.output(to: inputStream)
    }
}

extension TCPSocket {
    /// Create a `TCPSocketStream` for this socket.
    public func stream(bufferSize: Int = 4096, on worker: Worker) {
        self.stream(bufferSize: bufferSize, on: worker)
    }
}
