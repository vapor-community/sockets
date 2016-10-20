//
//  SocketOptions+Deprecated.swift
//  Socks
//
//  Created by Andreas Ley on 20.10.16.
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
    
    /// Returns the current error code of the socket (0 if no error)
    @available(*, deprecated, message: "use getErrorCode() instead")
    public var errorCode: Int32 {
        return try! Self.getOption(descriptor: descriptor,
                                   level: SOL_SOCKET,
                                   name: SO_ERROR)
    }
    
    
    /// Keepalive messages enabled (if implemented by protocol)
    @available(*, deprecated, message: "use getKeepAlive/setKeepAlive instead")
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
    @available(*, deprecated, message: "use getReuseAddress/setReuseAddress instead")
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
    @available(*, deprecated, message: "use getReceivingTimeout/setReceivingTimeout instead")
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
    @available(*, deprecated, message: "use getSendingTimeout/setSendingTimeout instead")
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
