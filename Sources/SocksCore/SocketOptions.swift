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

extension Socket {
    
    //When we have throwing property setters, remove the bangs below
    
    /// Keepalive messages enabled (if implemented by protocol)
    public var keepAlive: Bool {
        nonmutating set {
            try! Self.setBoolOption(descriptor: self.descriptor,
                                    level: SOL_SOCKET,
                                    name: SO_KEEPALIVE,
                                    value: newValue)
        }
        get {
            return try! Self.getBoolOption(descriptor: self.descriptor,
                                           level: SOL_SOCKET,
                                           name: SO_KEEPALIVE)
        }
    }
    
    /// Binding allowed (under certain conditions) to an address or port already in use
    public var reuseAddress: Bool {
        nonmutating set {
            try! Self.setBoolOption(descriptor: self.descriptor,
                                    level: SOL_SOCKET,
                                    name: SO_REUSEADDR,
                                    value: newValue)
        }
        get {
            return try! Self.getBoolOption(descriptor: self.descriptor,
                                           level: SOL_SOCKET,
                                           name: SO_REUSEADDR)
        }
    }
}

extension Socket {
    
    static func setBoolOption(descriptor: Int32, level: Int32, name: Int32, value: Bool) throws {
        let val = value ? 1 : 0
        try setOption(descriptor: descriptor, level: level, name: name, value: val)
    }

    static func getBoolOption(descriptor: Int32, level: Int32, name: Int32) throws -> Bool {
        return try getOption(descriptor: descriptor, level: level, name: name) > 0
    }

    static func setOption<T>(descriptor: Int32, level: Int32, name: Int32, value: T) throws {
        var val = value
        guard setsockopt(descriptor, level, name, &val, socklen_t(sizeof(T))) != -1 else {
            throw Error(.OptionSetFailed(level: level, name: name, value: String(value)))
        }
    }
    
    static func getOption<T>(descriptor: Int32, level: Int32, name: Int32) throws -> T {
        var length = socklen_t(sizeof(T))
        var val = UnsafeMutablePointer<T>.init(allocatingCapacity: 1)
        defer {
            val.deinitialize()
            val.deallocateCapacity(1)
        }
        guard getsockopt(descriptor, level, name, val, &length) != -1 else {
            throw Error(.OptionGetFailed(level: level, name: name, type: String(T)))
        }
        return val.pointee
    }
}
