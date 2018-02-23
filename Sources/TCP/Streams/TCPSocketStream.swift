import Async
import Bits

/// An async `ByteStream` stream wrapper for `TCPSocket`.
public final class TCPSocketStream: ByteStream {
    /// See `InputStream.Input`
    public typealias Input = ByteBuffer

    /// See `OutputStream.Output`
    public typealias Output = ByteBuffer

    /// Internal socket source stream.
    internal let source: TCPSocketSource

    /// Internal socket sink stream.
    internal let sink: TCPSocketSink

    /// Internal stream init. Use socket convenience method.
    internal init(socket: TCPSocket, bufferSize: Int, on worker: Worker, onError: @escaping TCPSocketSink.ErrorHandler) {
        self.source = socket.source(on: worker, bufferSize: bufferSize)
        self.sink = socket.sink(on: worker, onError: onError)
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
    public func stream(bufferSize: Int = 4096, on worker: Worker, onError: @escaping TCPSocketSink.ErrorHandler) -> TCPSocketStream {
        return TCPSocketStream(socket: self, bufferSize: bufferSize, on: worker, onError: onError)
    }
    
    /// Create a `TCPSocketStream` for this socket.
    @available(*, deprecated)
    public func stream(bufferSize: Int = 4096, on worker: Worker) -> TCPSocketStream {
        return TCPSocketStream(socket: self, bufferSize: bufferSize, on: worker) { _, error in
            ERROR("Uncaught error in TCPSocketStream: \(error).")
            return
        }
    }
}
