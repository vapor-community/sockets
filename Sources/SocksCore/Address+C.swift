//
//  Address+C.swift
//  Socks
//
//  Created by Matthias Kreileder on 3/20/16.
//
//

#if os(Linux)
    import Glibc
    typealias socket_addrinfo = Glibc.addrinfo
#else
    import Darwin
    typealias socket_addrinfo = Darwin.addrinfo
#endif

//Pretty types -> C types

protocol InternetAddressResolver {
    func resolve(internetAddress: InternetAddress) throws -> ResolvedInternetAddress
}

// Brief:   Given a hostname and a service this struct returns a list of
//          IP and Port adresses that where obtained during the name resolution
//          e.g. "localhost" and "echo" as arguments will result in a list of
//          IP addresses of the machine that runs the program and port set to 7
//
struct Resolver: InternetAddressResolver{
    private let config: SocketConfig
    
    
    // config       -   the provided SocketConfig object guides the name resolution
    //                  the socketType and protocolType fields control which kind
    //                  kind of socket you want to create.
    //                  E.g. set them to .STREAM .TCP to obtain address for a TCP Stream socket
    //              -   Set the addressFamily field to .UNSPECIFIED if you don't care if the
    //                  name resolution leads to IPv4 or IPv6 addresses.
    init(config: SocketConfig){
        self.config = config
    }
    
    func resolve(internetAddress: InternetAddress) throws -> ResolvedInternetAddress {
        let resolvedInternetAddresses = try Resolver._resolve(socketConfig: self.config, internetAddress: internetAddress)
        return resolvedInternetAddresses
    }
    
    private static func _resolve(socketConfig: SocketConfig, internetAddress: InternetAddress) throws ->  ResolvedInternetAddress {
        
        //
        // Narrowing down the results we will get from the getaddrinfo call
        //
        var addressCriteria = socket_addrinfo.init()
        // IPv4 or IPv6
        addressCriteria.ai_family = socketConfig.addressFamily.toCType()
        addressCriteria.ai_flags = AI_PASSIVE
        addressCriteria.ai_socktype = socketConfig.socketType.toCType()
        addressCriteria.ai_protocol = socketConfig.protocolType.toCType()
        
        // The list of addresses that correspond to the hostname/service pair.
        // servinfo is the first node in a linked list of addresses that is empty
        // at this line
        var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
        // perform resolution
        let getaddrinfoReturnValue = getaddrinfo(internetAddress.hostname, internetAddress.port.toString(), &addressCriteria, &servinfo)
        guard getaddrinfoReturnValue == 0 else { throw Error(.IPAddressValidationFailed) }
        
        guard let addr = servinfo else { throw Error(.IPAddressResolutionFailed) }
        
        //this takes the first resolved address, potentially we should
        //get all of the addresses in the list and allow for iterative
        //connecting
        let firstSockAddrInfo = addr[0].ai_addr
        let firstSockAddr = UnsafeMutablePointer<sockaddr_storage>(firstSockAddrInfo)!.pointee
        let address = ResolvedInternetAddress(raw: firstSockAddr)
        freeaddrinfo(addr)
        return address
    }
}
