import libc

extension RawSocket {
    
    /// Control whether the socket calls are blocking or nonblocking
    public var blocking: Bool {
        get {
            if isClosed { return true }
            let flags = fcntl(descriptor.raw, F_GETFL, 0)
            return flags & O_NONBLOCK == 0
        }
        set {
            if isClosed { return }
            let flags = fcntl(descriptor.raw, F_GETFL, 0)
            let newFlags: Int32
            if newValue {
                newFlags = flags & ~O_NONBLOCK
            } else {
                newFlags = flags | O_NONBLOCK
            }
            _ = fcntl(descriptor.raw, F_SETFL, newFlags)
        }
    }
    
    /// Returns the current error code of the socket (0 if no error)
    public func getErrorCode() throws -> Int32
    {
        if isClosed { throw SocksError(.socketIsClosed) }
        return try descriptor.getOption(level: SOL_SOCKET, name: SO_ERROR)
    }
    
    /// Keepalive messages enabled (if implemented by protocol)
    public func getKeepAlive() throws -> Bool {
        if isClosed { throw SocksError(.socketIsClosed) }
        return try descriptor.getBoolOption(level: SOL_SOCKET, name: SO_KEEPALIVE)
    }
    public func setKeepAlive(_ newValue:Bool) throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        try descriptor.setBoolOption(level: SOL_SOCKET, name: SO_KEEPALIVE, value: newValue)
    }
    
    /// Binding allowed (under certain conditions) to an address or port already in use
    public func getReuseAddress() throws -> Bool {
        if isClosed { throw SocksError(.socketIsClosed) }
        return try descriptor.getBoolOption(level: SOL_SOCKET, name: SO_REUSEADDR)
    }
    public func setReuseAddress(_ newValue:Bool) throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        try descriptor.setBoolOption(level: SOL_SOCKET, name: SO_REUSEADDR, value: newValue)
    }
    
    /// Specify the receiving timeout until reporting an error
    /// Zero timeval means wait forever
    public func getReceivingTimeout() throws -> timeval {
        if isClosed { throw SocksError(.socketIsClosed) }
        return try descriptor.getOption(level: SOL_SOCKET, name: SO_RCVTIMEO)
    }
    public func setReceivingTimeout(_ newValue:timeval) throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        try descriptor.setOption(level: SOL_SOCKET, name: SO_RCVTIMEO, value: newValue)
    }
    
    /// Specify the sending timeout until reporting an error
    /// Zero timeval means wait forever
    public func getSendingTimeout() throws -> timeval {
        if isClosed { throw SocksError(.socketIsClosed) }
        return try descriptor.getOption(level: SOL_SOCKET, name: SO_SNDTIMEO)
    }
    public func setSendingTimeout(_ newValue:timeval) throws {
        if isClosed { throw SocksError(.socketIsClosed) }
        try descriptor.setOption(level: SOL_SOCKET, name: SO_SNDTIMEO, value: newValue)
    }

    public func setTimeout(_ timeout: Double) throws {
        try setSendingTimeout(timeval(seconds: timeout))
        try setReceivingTimeout(timeval(seconds: timeout))
    }
}


