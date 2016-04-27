//
//  Address+C.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
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
    func resolve(internetAddress: InternetAddress) throws -> [ResolvedInternetAddress]
}

// Brief:   Given given a hostname and a service this struct returns a list of
//          IP and Port adresses that where obtained during the name resolution
//          e.g. "localhost" and "echo" as arguments will result in a list of
//          IP addresses of the machine that runs the program and port set to 7
//
public struct Resolver : InternetAddressResolver{
    private let config : SocketConfig
    
    
    // config       -   the provided SocketConfig object guides the name resolution
    //                  the socketType and protocolType fields control which kind
    //                  kind of socket you want to create.
    //                  E.g. set them to .STREAM .TCP to obtain address for a TCP Stream socket
    //              -   Set the addressFamily field to .UNSPECIFIED if you don't care if the
    //                  name resolution leads to IPv4 or IPv6 addresses.
    public init(config : SocketConfig){
        self.config = config
    }
    
    public func resolve(internetAddress: InternetAddress) throws -> [ResolvedInternetAddress] {
        let resolvedInternetAddressesArray = try resolveHostnameAndServiceToIPAddresses(socketConfig: self.config, internetAddress: internetAddress)
        return resolvedInternetAddressesArray
    }
    
    private func resolveHostnameAndServiceToIPAddresses(socketConfig: SocketConfig,
                                                        internetAddress: InternetAddress) throws
                                                        ->  Array<ResolvedInternetAddress>
    {
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
    
    // Wrap linked list into array of ResolvedInternetAddress
    
    // we need to remember the head of the linked list to clean up the consumed memory on the head
    let head = servinfo
        
    var resolvedInternetAddressesArray = Array<ResolvedInternetAddress>()
    while(servinfo != nil){
        let singleAddress = ResolvedInternetAddress(internetAddress: internetAddress, resolvedCTypeAddress: (servinfo?.pointee)!)
        resolvedInternetAddressesArray.append(singleAddress)
        servinfo = servinfo?.pointee.ai_next
    }
    
    //
    //  FIXME:  The dynamically allocated linked list of socket_addrinfo objects
    //          should be deleted from the heap in order to prevent memory leaks
    //          However, when I [Matthias Kreileder] uncomment the line 'freeaddrinfo(head)'
    //          my code crashes at runtime :(
    //          In the code above I tried to COPY the socket_addrinfo into an array
    //          so that I can (in theory) safely free the memory allocated on the heap.
    //
    // Prevent memory leaks: getaddrinfo creates an unmanaged linked list on the heap
    //freeaddrinfo(head)
        
    return resolvedInternetAddressesArray
    }

}

//Pointer casting

func sockaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}

func sockaddr_storage_cast(p : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}


