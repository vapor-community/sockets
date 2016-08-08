//
//  SocketOptions.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/7/16.
//
//

#if os(Linux)
    import Glibc
    private let s_socket = Glibc.socket
    private let s_close = Glibc.close
#else
    import Darwin
    private let s_socket = Darwin.socket
    private let s_close = Darwin.close
#endif

extension RawSocket {
    
    /// Control whether the socket calls are blocking or nonblocking
    public var blocking: Bool {
        get {
            let flags = fcntl(descriptor, F_GETFL, 0)
            return flags & O_NONBLOCK == 0
        }
        nonmutating set {
            let flags = fcntl(descriptor, F_GETFL, 0)
            let newFlags: Int32
            if newValue {
                newFlags = flags & ~O_NONBLOCK
            } else {
                newFlags = flags | O_NONBLOCK
            }
            _ = fcntl(descriptor, F_SETFL, newFlags)
        }
    }
    
    /// Returns the current error code of the socket (0 if no error) 
    public var errorCode: Int32 {
        return try! Self.getOption(descriptor: descriptor,
                                   level: SOL_SOCKET,
                                   name: SO_ERROR)
    }
    
    //When we have throwing property setters, remove the bangs below
    
    /// Keepalive messages enabled (if implemented by protocol)
    public var keepAlive: Bool {
        nonmutating set {
            try! Self.setBoolOption(descriptor: descriptor,
                                    level: SOL_SOCKET,
                                    name: SO_KEEPALIVE,
                                    value: newValue)
        }
        get {
            return try! Self.getBoolOption(descriptor: descriptor,
                                           level: SOL_SOCKET,
                                           name: SO_KEEPALIVE)
        }
    }
    
    /// Binding allowed (under certain conditions) to an address or port already in use
    public var reuseAddress: Bool {
        nonmutating set {
            try! Self.setBoolOption(descriptor: descriptor,
                                    level: SOL_SOCKET,
                                    name: SO_REUSEADDR,
                                    value: newValue)
        }
        get {
            return try! Self.getBoolOption(descriptor: descriptor,
                                           level: SOL_SOCKET,
                                           name: SO_REUSEADDR)
        }
    }
    
    /// Specify the receiving timeout until reporting an error
    /// Zero timeval means wait forever
    public var receivingTimeout: timeval {
        nonmutating set {
            try! Self.setOption(descriptor: descriptor,
                                level: SOL_SOCKET,
                                name: SO_RCVTIMEO,
                                value: newValue)
        }
        get {
            return try! Self.getOption(descriptor: descriptor,
                                       level: SOL_SOCKET,
                                       name: SO_RCVTIMEO)
        }
    }
    
    /// Specify the sending timeout until reporting an error
    /// Zero timeval means wait forever
    public var sendingTimeout: timeval {
        nonmutating set {
            try! Self.setOption(descriptor: descriptor,
                                level: SOL_SOCKET,
                                name: SO_SNDTIMEO,
                                value: newValue)
        }
        get {
            return try! Self.getOption(descriptor: descriptor,
                                       level: SOL_SOCKET,
                                       name: SO_SNDTIMEO)
        }
    }
}

extension RawSocket {
    
    static func disableSIGPIPE(descriptor: Descriptor) throws {
        // prevents SIGPIPE from killing process
        // only works on OS X
        #if !os(Linux)
        try setOption(descriptor: descriptor, level: SOL_SOCKET, name: SO_NOSIGPIPE, value: 1)
        #endif
    }
    
    static func setBoolOption(descriptor: Int32, level: Int32, name: Int32, value: Bool) throws {
        let val = value ? 1 : 0
        try setOption(descriptor: descriptor, level: level, name: name, value: val)
    }

    static func getBoolOption(descriptor: Int32, level: Int32, name: Int32) throws -> Bool {
        return try getOption(descriptor: descriptor, level: level, name: name) > 0
    }

    static func setOption<T>(descriptor: Int32, level: Int32, name: Int32, value: T) throws {
        var val = value
        guard setsockopt(descriptor, level, name, &val, socklen_t(MemoryLayout<T>.stride)) != -1 else {
            throw SocksError(.optionSetFailed(level: level, name: name, value: String(describing: value)))
        }
    }
    
    static func getOption<T>(descriptor: Int32, level: Int32, name: Int32) throws -> T {
        var length = socklen_t(MemoryLayout<T>.stride)
        var val = UnsafeMutablePointer<T>.allocate(capacity: 1)
        defer {
            val.deinitialize()
            val.deallocate(capacity: 1)
        }
        guard getsockopt(descriptor, level, name, val, &length) != -1 else {
            throw SocksError(.optionGetFailed(level: level, name: name, type: String(describing: T.self)))
        }
        return val.pointee
    }
}

extension timeval: Equatable { }
public func ==(lhs: timeval, rhs: timeval) -> Bool {
    return lhs.tv_sec == rhs.tv_sec && lhs.tv_usec == rhs.tv_usec
}

