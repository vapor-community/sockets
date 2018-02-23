import Async
import Bits
import Dispatch
import Foundation

private let maxExcessSignalCount: Int = 2

/// Data stream wrapper for a dispatch socket.
public final class TCPSocketSink: Async.InputStream {
    /// Able to handle errors that are thrown to the Sink
    public typealias ErrorHandler = (TCPSocketSink, Error) -> ()
    
    /// See InputStream.Input
    public typealias Input = ByteBuffer

    /// The client stream's underlying socket.
    public var socket: TCPSocket

    /// Data being fed into the client stream is stored here.
    private var inputBuffer: ByteBuffer?

    /// Stores write event source.
    private var writeSource: EventSource?

    /// A strong reference to the current eventloop
    private var eventLoop: EventLoop

    /// True if this sink has been closed
    private var isClosed: Bool

    /// Currently waiting done callback
    private var currentReadyPromise: Promise<Void>?

    /// If true, the read source has been suspended
    private var sourceIsSuspended: Bool

    /// The current number of signals received while downstream was not ready
    /// since it was last ready
    private var excessSignalCount: Int
    
    /// This closure will be called with an error thrown from upstream
    private let onError: ErrorHandler

    /// Creates a new `SocketSink`
    internal init(socket: TCPSocket, on worker: Worker, onError: @escaping ErrorHandler) {
        self.socket = socket
        self.eventLoop = worker.eventLoop
        self.inputBuffer = nil
        self.isClosed = false
        self.sourceIsSuspended = true
        self.excessSignalCount = 0
        self.onError = onError
        let writeSource = self.eventLoop.onWritable(descriptor: socket.descriptor, writeSourceSignal)
        self.writeSource = writeSource
    }

    /// See InputStream.input
    public func input(_ event: InputEvent<ByteBuffer>) {
        DEBUG("TCPSocketSink.(\(event))")
        // update variables
        switch event {
        case .next(let input, let ready):
            guard inputBuffer == nil else {
                ERROR("SocketSink upstream is illegally overproducing input buffers.")
                return
            }
            inputBuffer = input
            guard currentReadyPromise == nil else {
                ERROR("SocketSink currentReadyPromise illegally not nil during input.")
                return
            }
            currentReadyPromise = ready
            resumeIfSuspended()
        case .close:
            close()
        case .error(let e):
            onError(self, e)
        }
    }

    /// Cancels reading
    public func close() {
        DEBUG("TCPSocketSink.close()")
        guard !isClosed else {
            return
        }
        guard let writeSource = self.writeSource else {
            ERROR("SocketSink writeSource illegally nil during close.")
            return
        }
        writeSource.cancel()
        socket.close()
        self.writeSource = nil
        isClosed = true
    }

    /// Writes the buffered data to the socket.
    private func writeData(ready: Promise<Void>) {
        DEBUG("TCPSocketSink.writeData(\(ready))")
        guard !socket.isClosed else {
            close()
            return
        }

        do {
            guard let buffer = self.inputBuffer else {
                ERROR("Unexpected nil SocketSink inputBuffer during writeData")
                return
            }

            DEBUG("TCPSocketSink.buffer = \(String(bytes: buffer, encoding: .ascii) ?? "nil")")
            let write = try socket.write(from: buffer)
            switch write {
            case .success(let count):
                switch count {
                case buffer.count:
                    self.inputBuffer = nil
                    ready.complete() //onNextTick: eventLoop)
                default:
                    inputBuffer = ByteBuffer(
                        start: buffer.baseAddress?.advanced(by: count),
                        count: buffer.count - count
                    )
                    writeData(ready: ready)
                }
            case .wouldBlock:
                resumeIfSuspended()
                guard currentReadyPromise == nil else {
                    ERROR("SocketSink currentReadyPromise illegally not nil during wouldBlock.")
                    return
                }
                currentReadyPromise = ready
            }
        } catch {
            self.error(error)
            ready.complete() //onNextTick: eventLoop)
        }
    }

    /// Called when the write source signals.
    private func writeSourceSignal(isCancelled: Bool) {
        DEBUG("TCPSocketSink.writeSourceSignal(\(isCancelled))")
        guard !isCancelled else {
            // source is cancelled, we will never receive signals again
            close()
            return
        }

        guard inputBuffer != nil else {
            // no data ready for socket yet
            excessSignalCount = excessSignalCount &+ 1
            if excessSignalCount >= maxExcessSignalCount {
                guard let writeSource = self.writeSource else {
                    ERROR("SocketSink writeSource illegally nil during signal.")
                    return
                }
                DEBUG("TCPSocketSink [suspending write]")
                writeSource.suspend()
                sourceIsSuspended = true
            }
            return
        }

        guard let ready = currentReadyPromise else {
            ERROR("SocketSink currentReadyPromise illegaly nil during signal.")
            return
        }
        currentReadyPromise = nil
        writeData(ready: ready)
    }

    private func resumeIfSuspended() {
        DEBUG("TCPSocketSink.resumeIfSuspended()")
        guard sourceIsSuspended else {
            return
        }

        guard let writeSource = self.writeSource else {
            ERROR("SocketSink writeSource illegally nil during resumeIfSuspended.")
            return
        }
        sourceIsSuspended = false
        // start listening for ready notifications
        writeSource.resume()
    }
}

/// MARK: Create

extension TCPSocket {
    /// Creates a data stream for this socket on the supplied event loop.
    public func sink(on eventLoop: Worker, onError: @escaping TCPSocketSink.ErrorHandler) -> TCPSocketSink {
        return .init(socket: self, on: eventLoop, onError: onError)
    }
    
    /// Creates a data stream for this socket on the supplied event loop.
    @available(*, deprecated)
    public func sink(on eventLoop: Worker) -> TCPSocketSink {
        return .init(socket: self, on: eventLoop) { _, error in
            ERROR("Uncaught error in TCPSocketSink: \(error).")
            return
        }
    }
}
