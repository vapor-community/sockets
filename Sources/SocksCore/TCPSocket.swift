//
//  Socket+Impl.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

import Dispatch

#if os(Linux)
    import Glibc
    private let socket_bind = Glibc.bind
    private let socket_connect = Glibc.connect
    private let socket_listen = Glibc.listen
    private let socket_accept = Glibc.accept
    private let socket_recv = Glibc.recv
    private let socket_send = Glibc.send
    private let socket_close = Glibc.close
    private let SOCKET_NOSIGNAL = Glibc.MSG_NOSIGNAL
#else
    import Darwin
    private let socket_connect = Darwin.connect
    private let socket_bind = Darwin.bind
    private let socket_listen = Darwin.listen
    private let socket_accept = Darwin.accept
    private let socket_recv = Darwin.recv
    private let socket_send = Darwin.send
    private let socket_close = Darwin.close
    private let SOCKET_NOSIGNAL = Darwin.SO_NOSIGPIPE
#endif

public protocol TCPSocket: RawSocket { }

public protocol TCPWriteableSocket: TCPSocket { }

public protocol TCPReadableSocket: TCPSocket { }

extension TCPReadableSocket {

    public func recv(maxBytes: Int = BufferCapacity) throws -> [UInt8] {
        let data = Bytes(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let receivedBytes = socket_recv(self.descriptor, data.rawBytes, data.capacity, flags)
        guard receivedBytes != -1 else {
            if errno == ECONNRESET {
                // closed by peer, need to close this side. 
                // Since this is not an error, no need to throw unless the close
                // itself throws an error.
                _ = try self.close()
                return []
            } else {
                throw SocksError(.readFailed)
            }
        }
      
        guard receivedBytes > 0 else {
            // receiving 0 indicates a proper close .. no error.
            // attempt a close, no failure possible because throw indicates already closed
            // if already closed, no issue. 
            // do NOT propogate as error
            _ = try? self.close()
            return []
        }
        let finalBytes = data.characters[0..<receivedBytes]
        return Array(finalBytes)
    }

    public func recvAll() throws -> [UInt8] {
        var buffer: [UInt8] = []
        let chunkSize = 512
        while true {
            let newData = try self.recv(maxBytes: chunkSize)
            buffer.append(contentsOf: newData)
            if newData.count < chunkSize {
                break
            }
        }
        return buffer
    }
}


extension TCPWriteableSocket {

    public func send(data: [UInt8]) throws {
        let len = data.count
        let flags = Int32(SOCKET_NOSIGNAL) //FIXME: allow setting flags with a Swift enum
        let sentLen = socket_send(self.descriptor, data, len, flags)
        guard sentLen == len else { throw SocksError(.sendFailedToSendAllBytes) }
    }
}

public class TCPInternetSocket: InternetSocket, TCPSocket, TCPReadableSocket, TCPWriteableSocket {

    public private(set) var descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress
    public private(set) var closed: Bool
    private var sendingBuffer = [UInt8]()
    
    // the DispatchSource if the socket is being watched for reads
    private var watchingSource: DispatchSourceRead?

    // the DispatchSource used to write if the socket is being watched
    private var sendingSource: DispatchSourceWrite?
    private let sendingQueue = DispatchQueue(label: "SocksCoreNonblockingSendingQueue")

    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try TCPInternetSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
        self.closed = false

        try setReuseAddress(true)
    }
    
    deinit {
        // The socket needs to be closed (to close the underlying file descriptor). 
        // If descriptors aren't properly freed, the system will run out sooner or later.
        try? self.close()
    }

    public convenience init(address: InternetAddress) throws {
        var conf: SocketConfig = .TCP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        try self.init(descriptor: nil, config: conf, address: resolved)
    }

    public func connect() throws {
        if closed { throw SocksError(.socketIsClosed) }
        let res = socket_connect(self.descriptor, address.raw, address.rawLen)
        guard res > -1 else { throw SocksError(.connectFailed) }
    }

    public func connect(withTimeout timeout: Double?) throws {
        if closed { throw SocksError(.socketIsClosed) }

        guard let to = timeout else {
            try connect()
            return
        }

        //set to nonblocking
        self.blocking = false

        //set back to blocking at the end
        defer { self.blocking = true }

        //call connect
        do {
            try connect()
        } catch {
            //only allow error "in progress"
            guard let err = error as? SocksError, err.number == EINPROGRESS else {
                throw error
            }
        }

        //wait for writeable socket or timeout
        let (_, writes, _) = try select(writes: [descriptor], timeout: timeval(seconds: to))
        guard !writes.isEmpty else {
            throw SocksError(.connectTimedOut)
        }

        //ensure no error was encountered
        let err = try self.getErrorCode()
        guard err == 0 else {
            throw SocksError(.connectFailedWithSocketErrorCode(err))
        }
    }

    public func listen(queueLimit: Int32 = 4096) throws {
        if closed { throw SocksError(.socketIsClosed) }
        let res = socket_listen(self.descriptor, queueLimit)
        guard res > -1 else { throw SocksError(.listenFailed) }
    }

    public func accept() throws -> TCPInternetSocket {
        if closed { throw SocksError(.socketIsClosed) }
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        let clientSocketDescriptor = socket_accept(self.descriptor, addrSockAddr, &length)
        guard clientSocketDescriptor > -1 else {
            addr.deallocate(capacity: 1)
            if errno == SocksError.interruptedSystemCall {
                return try accept()
            }
            throw SocksError(.acceptFailed)
        }
        let clientAddress = ResolvedInternetAddress(raw: addr)
        let clientSocket = try TCPInternetSocket(descriptor: clientSocketDescriptor,
                                                 config: config,
                                                 address: clientAddress)
        return clientSocket
    }

    public func close() throws {
        if closed { return }
        stopWatching()
        closed = true
        if socket_close(self.descriptor) != 0 {
            if errno == EBADF {
                self.descriptor = -1
                throw SocksError(.socketIsClosed)
            } else {
                closed = false
                throw SocksError(.closeSocketFailed)
            }
        }
        // set descriptor to -1 to prevent further use
        self.descriptor = -1
    }
    
    /**
        Start watching the socket for available data and execute the `handler`
        on the specified queue if data is ready to be received.
        Watching sets the socket to nonblocking.
    */
    public func startWatching(on queue: DispatchQueue, handler: @escaping () -> ()) throws {
        try startWatching(on: queue, cancel: nil, handler: handler)
    }

    /**
        Start watching the socket for available data and execute the `handler`
        on the specified queue if data is ready to be received.
        If a `cancel` handler was passed, it will be run when watching stops (e.g. if the socket is closed).
        Watching sets the socket to nonblocking.
    */
    public func startWatching(on queue: DispatchQueue, cancel: (() -> ())?, handler: @escaping () -> ()) throws {
        
        if watchingSource != nil {
            throw SocksError(.generic("Socket is already being watched"))
        }
        
        // dispatch sources only work on non-blocking sockets
        self.blocking = false
        
        // create a read source from the socket's descriptor that will execute the handler on the specified queue if data is ready to be read
        let newSource = DispatchSource.makeReadSource(fileDescriptor: self.descriptor, queue: queue)
        newSource.setEventHandler(handler:handler)
        newSource.setCancelHandler(handler: cancel)
        newSource.resume()
        // this source need to be retained as long as the socket lives (or watching will end)
        watchingSource = newSource

        #if !os(Linux)
            // libdispatch on Linux (which uses epoll) has a bug that prevents using read and write sources on the same descriptor: https://bugs.swift.org/browse/SR-3360
            
            // create a read source from the socket's descriptor that will execute the handler on the specified queue if data is ready to be read
            let newWriteSource = DispatchSource.makeWriteSource(fileDescriptor: self.descriptor, queue: queue)
            newWriteSource.setEventHandler(handler: sendFromBuffer)
            sendingSource = newWriteSource
        #endif
    }

    public func send(data: [UInt8]) throws {
        // if there's no sendingSource, assume the socket is blocking and send accordingly
        if self.sendingSource == nil {
            let len = data.count
            let flags = Int32(SOCKET_NOSIGNAL) //FIXME: allow setting flags with a Swift enum
            let sentLen = socket_send(self.descriptor, data, len, flags)
            guard sentLen == len else { throw SocksError(.sendFailedToSendAllBytes) }
            return
        }
        
        // assume socket is nonblocking; buffer data and send whenever the socket is ready.
        // accessing the buffer needs to be synchronized to prevent multithreading issues.
        #if os(Linux)
            sendingBuffer.append(contentsOf: data)
            DispatchQueue.global(qos: .background).async {
                self.sendFromBuffer()
            }
        #else
            sendingQueue.sync {
                // if no data is waiting in the buffer, the source was suspended and needs to be resumed
                let sourceNeedsToBeResumed = self.sendingBuffer.count == 0
                sendingBuffer.append(contentsOf: data)
                if sourceNeedsToBeResumed {
                    self.sendingSource?.resume()
                }
            }
        #endif
    }
    
    /**
        Sends as much data from `sendingBuffer` as the (nonblocking) socket can handle
        and remove sent data from the buffer.
     */
    private func sendFromBuffer() {
        sendingQueue.sync {
            let flags = Int32(SOCKET_NOSIGNAL) //FIXME: allow setting flags with a Swift enum
            let bytesSent = socket_send(self.descriptor, sendingBuffer, sendingBuffer.count, flags)
            if bytesSent > 0 {
                sendingBuffer.removeFirst(bytesSent)
            }
            
            #if os(Linux)
                if sendingBuffer.count > 0 && bytesSent >= 0 { // Don't schedule more sendFromBuffers() if we get an error in the socket_send() call
                    // call again
                    DispatchQueue.global(qos: .background).async {
                        self.sendFromBuffer()
                    }
                }
            #else
                if sendingBuffer.count == 0 {
                    // if there's no more data to be sent, the source is suspended until there's more
                    self.sendingSource?.suspend()
                }
            #endif
        }
    }

    /**
        Stops watching the socket for available data. 
        Runs the `cancel` handler passed when starting watching.
        Sets the socket to `blocking` again.
    */
    public func stopWatching() {
        watchingSource?.cancel()
        watchingSource = nil
        sendingQueue.sync {
            sendingSource?.cancel()
            if sendingBuffer.count == 0 {
                // if the sendingBuffer is empty, the queue is suspended and needs to be resumed before releasing it
                self.sendingSource?.resume()
            }
            sendingSource = nil
        }
        self.blocking = true
    }
}

public class TCPEstablishedSocket: TCPSocket {

    public let closed = false
    public let descriptor: Descriptor

    public init(descriptor: Descriptor) {
        self.descriptor = descriptor
    }
}

public class TCPEstablishedWriteableSocket: TCPEstablishedSocket, TCPWriteableSocket { }
public class TCPEstablishedReadableSocket: TCPEstablishedSocket, TCPReadableSocket { }
