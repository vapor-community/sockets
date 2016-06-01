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

public class UDPSocket: InternetSocket {
    
    public let descriptor: Descriptor
    public let config: SocketConfig
    public let address: ResolvedInternetAddress
    
    public required init(descriptor: Descriptor?, config: SocketConfig, address: ResolvedInternetAddress) throws {
        
        if let descriptor = descriptor {
            self.descriptor = descriptor
        } else {
            self.descriptor = try UDPSocket.createNewSocket(config: config)
        }
        self.config = config
        self.address = address
    }
    
    public convenience init(address: InternetAddress) throws {
        var config: SocketConfig = .UDP(addressFamily: address.addressFamily)
        let resolved = try address.resolve(with: config)
        config = try config.adjusted(for: resolved)
        try self.init(descriptor: nil, config: config, address: resolved)
    }
    
    public func recvfrom(maxBytes: Int = BufferCapacity) throws -> (data: [UInt8], sender: ResolvedInternetAddress) {
        let data = Bytes(capacity: maxBytes)
        let flags: Int32 = 0 //FIXME: allow setting flags with a Swift enum
        
        var length = socklen_t(sizeof(sockaddr_storage))
        let addr = UnsafeMutablePointer<sockaddr>.init(allocatingCapacity: 1)
        
        let receivedBytes = socket_recvfrom(
            self.descriptor,
            data.rawBytes,
            data.capacity,
            flags,
            addr,
            &length
        )
        guard receivedBytes > -1 else { throw Error(.ReadFailed) }
        
        let clientAddress = ResolvedInternetAddress(raw: addr.pointee)
        addr.deallocateCapacity(1)
        
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
        guard sentLen == len else { throw Error(.SendFailedToSendAllBytes) }
    }
}
