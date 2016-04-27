//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

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
        
        let resolvedInternetAddressList = try resolver.resolve(internetAddress: address)
        
        guard !resolvedInternetAddressList.isEmpty else {throw Error(.IPAddressValidationFailed) }
        
        //  NOTE: The family field must be set according to the ResolvedInternetAddress
        //  address NOT according to the SocketConfig
        //  Why that? SocketConfig.familiyType can be set to Unspecified in order to
        //  transparently use IPv4 and IPv6
        //  but the RawSocket needs a concrete IPv4 or IPv6 argument => we 
        //  use the family field from the resolved address
        //
        //  I [Matthias Kreileder] admit this if - else part here is ugly but we need
        //  the "backwards resolution" i.e. given a C Type for the Address Family we 
        //  want to create a "Pretty Type", namely a SocketConfig
        //
        if (resolvedInternetAddressList[0].resolvedCTypeAddress.ai_family == AF_INET){
            let resolvedSocketConfig = SocketConfig(addressFamily: .Inet, socketType: socketConfig.socketType, protocolType: socketConfig.protocolType)
            
            let raw = try RawSocket(socketConfig: resolvedSocketConfig)
            
            self.init(rawSocket: raw, address: resolvedInternetAddressList[0])
            
        }
        else{
            let resolvedSocketConfig = SocketConfig(addressFamily: .Inet6, socketType: socketConfig.socketType, protocolType: socketConfig.protocolType)
            
            let raw = try RawSocket(socketConfig: resolvedSocketConfig)
            
            self.init(rawSocket: raw, address: resolvedInternetAddressList[0])
        }

     }
    
    
    public func close() throws {
        try self.rawSocket.close()
    }
}
