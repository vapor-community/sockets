//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

public class InternetSocket: Socket {
    
    public let rawSocket: RawSocket
    public let address: ResolvedInternetAddress
    
    public var descriptor: Descriptor {
        return self.rawSocket.descriptor
    }
    
    public init(rawSocket: RawSocket, address: ResolvedInternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
    
    public convenience init(socketConfig: SocketConfig, address: InternetAddress) throws {
        
        let resolver = Resolver(config: socketConfig)
        let resolvedAddress = try resolver.resolve(internetAddress: address)

        //  NOTE: The family field must be set according to the ResolvedInternetAddress
        //  address NOT according to the SocketConfig
        //  Why that? SocketConfig.familyType can be set to Unspecified in order to
        //  transparently use IPv4 and IPv6
        //  but the RawSocket needs a concrete IPv4 or IPv6 argument => we
        //  use the family field from the resolved address
        
        let addressFamily = try resolvedAddress.addressFamily()
        
        // validate it's a concrete family type
        switch addressFamily {
        case .Inet, .Inet6: break //all good
        default: throw Error(ErrorReason.ConcreteSocketAddressFamilyRequired)
        }
        
        let resolvedSocketConfig = SocketConfig(addressFamily: addressFamily, socketType: socketConfig.socketType, protocolType: socketConfig.protocolType)
        let raw = try RawSocket(socketConfig: resolvedSocketConfig)
        self.init(rawSocket: raw, address: resolvedAddress)
    }
    
    public func close() throws {
        try self.rawSocket.close()
    }
}
