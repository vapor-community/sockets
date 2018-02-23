import Async
import Bits
import COperatingSystem
import Foundation

/// Any TCP socket. It doesn't specify being a server or client yet.
public final class TCPSocket {
    /// The file descriptor related to this socket
    public var descriptor: Int32

    /// The remote's address
    public var address: TCPAddress?

    /// True if the socket is non blocking
    public let isNonBlocking: Bool

    /// True if the socket should re-use addresses
    public let shouldReuseAddress: Bool

    /// True if the socket has been closed.
    public var isClosed: Bool {
        return descriptor < 0
    }

    /// Creates a TCP socket around an existing descriptor
    public init(
        established: Int32,
        isNonBlocking: Bool,
        shouldReuseAddress: Bool,
        address: TCPAddress?
    ) {
        self.descriptor = established
        self.isNonBlocking = isNonBlocking
        self.shouldReuseAddress = shouldReuseAddress
        self.address = address
    }

    /// Creates a new TCP socket
    public convenience init(
        isNonBlocking: Bool = true,
        shouldReuseAddress: Bool = false
    ) throws {
        let sockfd = socket(AF_INET, SOCK_STREAM, 0)
        guard sockfd > 0 else {
            throw TCPError.posix(errno, identifier: "socketCreate", source: .capture())
        }

        if isNonBlocking {
            // Set the socket to async/non blocking I/O
            guard fcntl(sockfd, F_SETFL, O_NONBLOCK) == 0 else {
                _ = COperatingSystem.close(sockfd)
                throw TCPError.posix(errno, identifier: "setNonBlocking", source: .capture())
            }
        }

        if shouldReuseAddress {
            var yes = 1
            let intSize = socklen_t(MemoryLayout<Int>.size)

            guard
                setsockopt(sockfd, SOL_SOCKET, SO_REUSEPORT, &yes, intSize) == 0,
                setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, intSize) == 0
            else {
                _ = COperatingSystem.close(sockfd)
                throw TCPError.posix(errno, identifier: "setReuseAddress", source: .capture())
            }
        }

        self.init(
            established: sockfd,
            isNonBlocking: isNonBlocking,
            shouldReuseAddress: shouldReuseAddress,
            address: nil
        )
    }

    /// Disables broken pipe from signaling this process.
    /// Broken pipe is common on the internet and if uncaught
    /// it will kill the process.
    public func disablePipeSignal() {
        signal(SIGPIPE, SIG_IGN)

        #if !os(Linux)
            var n = 1
            setsockopt(self.descriptor, SOL_SOCKET, SO_NOSIGPIPE, &n, numericCast(MemoryLayout<Int>.size))
        #endif

        // TODO: setsockopt(self.descriptor, SOL_TCP, TCP_NODELAY, &n, numericCast(MemoryLayout<Int>.size)) ?
    }

    /// Read data from the socket into the supplied buffer.
    /// Returns the amount of bytes actually read.
    public func read(into buffer: MutableByteBuffer) throws -> TCPSocketStatus {
        let receivedBytes = COperatingSystem.read(descriptor, buffer.baseAddress!, buffer.count)

        guard receivedBytes != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try read(into: buffer)
            case ECONNRESET:
                // closed by peer, need to close this side.
                // Since this is not an error, no need to throw unless the close
                // itself throws an error.
                _ = close()
                return .success(count: 0)
            case EAGAIN, EWOULDBLOCK:
                // no data yet
                return .wouldBlock
            case EBADF:
                assert(isClosed, "EBADF when socket not closed")
                throw TCPError(identifier: "read", reason: "Socket is closed.", source: .capture())
            default:
                throw TCPError.posix(errno, identifier: "read", source: .capture())
            }
        }

        guard receivedBytes > 0 else {
            // receiving 0 indicates a proper close .. no error.
            // attempt a close, no failure possible because throw indicates already closed
            // if already closed, no issue.
            // do NOT propogate as error
            self.close()
            return .success(count: 0)
        }

        return .success(count: receivedBytes)
    }

    /// Writes all data from the pointer's position with the length specified to this socket.
    public func write(from buffer: ByteBuffer) throws -> TCPSocketStatus {
        guard let pointer = buffer.baseAddress else {
            return .success(count: 0)
        }

        let sent = send(descriptor, pointer, buffer.count, 0)

        guard sent != -1 else {
            switch errno {
            case EINTR:
                // try again
                return try write(from: buffer)
            case ECONNRESET:
                self.close()
                return .success(count: 0)
            case EBADF:
                assert(isClosed, "EBADF when socket not closed")
                throw TCPError(identifier: "write", reason: "Socket is closed.", source: .capture())
            case EAGAIN, EWOULDBLOCK:
                return .wouldBlock
            default:
                throw TCPError.posix(errno, identifier: "write", source: .capture())
            }
        }

        return .success(count: sent)
    }

    /// Closes the socket
    public func close() {
        guard descriptor != -1 else {
            return
        }
        _ = COperatingSystem.close(descriptor)
        descriptor = -1
    }

    deinit {
        // print("\(type(of: self)).\(#function)")
    }
}
