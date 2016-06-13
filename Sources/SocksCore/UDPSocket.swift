//
//  UDPSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/1/16.
//
//

#if os(Linux)
    import Glibc
    private let socket_recvfrom = Glibc.recvfrom
    private let socket_sendto = Glibc.sendto
#else
    import Darwin
    private let socket_recvfrom = Darwin.recvfrom
    private let socket_sendto = Darwin.sendto
#endif

public class UDPInternetSocket: InternetSocket {
    
    public let descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress

    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try UDPInternetSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
        
        self.reuseAddress = true
    }
    
    public convenience init(address: InternetAddress) throws {
        var conf: SocketConfig = .UDP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: &conf)
        try self.init(descriptor: nil, config: conf, address: resolved)
    }
    
    public func recvfrom(maxBytes: Int = BufferCapacity) throws -> (data: [UInt8], sender: ResolvedInternetAddress) {
        let data = Bytes(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        
        var length = socklen_t(sizeof(sockaddr_storage))
        let addr = UnsafeMutablePointer<sockaddr_storage>.init(allocatingCapacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(addr)
        
        let receivedBytes = socket_recvfrom(
            self.descriptor,
            data.rawBytes,
            data.capacity,
            flags,
            addrSockAddr,
            &length
        )
        guard receivedBytes > -1 else {
            addr.deallocateCapacity(1)
            throw Error(.readFailed)
        }
        
        let clientAddress = ResolvedInternetAddress(raw: addr)
        
        let finalBytes = data.characters[0..<receivedBytes]
        let out = Array(finalBytes.map({ UInt8($0) }))
        return (data: out, sender: clientAddress)
    }
    
    public func sendto(data: [UInt8], address: ResolvedInternetAddress? = nil) throws {
        let len = data.count
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        let destination = address ?? self.address
        
        let sentLen = socket_sendto(
            self.descriptor,
            data,
            len,
            flags,
            destination.raw,
            destination.rawLen
        )
        guard sentLen == len else { throw Error(.sendFailedToSendAllBytes) }
    }
}
