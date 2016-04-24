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

extension InternetAddress {
    
    func toCType() throws -> sockaddr {
        
        var addr = sockaddr_in()
        
        switch self.address {
        case .Hostname(let hostname):
            //hostname must be converted to ip
            addr.sin_addr = try InternetAddress.getAddressFromHostname(hostname)
        case .IPv4(let ipBytes4):
            //we got an IP, validate it
            let str = ipBytes4.toArray().periodSeparatedString()
            guard inet_pton(AF_INET, str, &addr.sin_addr) == 1 else {
                throw Error(ErrorReason.IPAddressValidationFailed)
            }
        case .IPv6(let dummy):
            print(dummy)
        }
        
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(htons(in_port_t(self.port)))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        
        let res = sockaddr_cast(&addr).pointee
        return res
    }
    
    private static func getAddressFromHostname(hostname: String) throws -> in_addr {
        
        let _hostInfo = gethostbyname(hostname)
        guard _hostInfo != nil else {
            throw Error(.FailedToGetIPFromHostname(hostname))
        }
        let hostInfo = _hostInfo.pointee
        guard hostInfo.h_addrtype == AF_INET else {
            throw Error(.FailedToGetIPFromHostname("No IPv4 address"))
        }
        guard hostInfo.h_addr_list != nil else {
            throw Error(.FailedToGetIPFromHostname("List is empty"))
        }
        
        let addrStruct = sockadd_list_cast(hostInfo.h_addr_list)[0].pointee
        return addrStruct
    }
}

protocol InternetAddressResolver {
    func resolve(internetAddress : KclInternetAddress) -> Array<KclResolvedInternetAddress>
}

public struct Resolver : InternetAddressResolver{
    private let config : SocketConfig
    public init(config : SocketConfig){
        self.config = config
    }
    
    public func resolve(internetAddress : KclInternetAddress) -> Array<KclResolvedInternetAddress>{
        let resolvedInternetAddressesArray = try!resolveHostnameAndServiceToIPAddresses(self.config, internetAddress: internetAddress)
        //
        // TODO: Consider try and catch or other tests (if array contains 0 elements or something like that)
        //
        return resolvedInternetAddressesArray
    }
    
    private func resolveHostnameAndServiceToIPAddresses(socketConfig : SocketConfig,
                                                        internetAddress : KclInternetAddress) throws
                                                        ->  Array<KclResolvedInternetAddress>
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
        
    var resolvedInternetAddressesArray = Array<KclResolvedInternetAddress>()
    while(servinfo != nil){
        let singleAddress = KclResolvedInternetAddress(internetAddress: internetAddress, resolvedCTypeAddress: servinfo.pointee)
        resolvedInternetAddressesArray.append(singleAddress)
        servinfo = servinfo.pointee.ai_next
    }
        
    // Prevent memory leaks: getaddrinfo creates an unmanaged linked list on the heap
    //freeaddrinfo(head)
        
    return resolvedInternetAddressesArray
    }

}

/*
 
 protocol InternetAddressResolver {
 
    public func resolve(InternetAddress) -> List<ResolvedInternetAddress>
 
 }
 
 public class InternetAddressResolver {
 
    // List of obtained addresses
    addressList : List<UnsafePointer<addinfo>>
 
    // hostname can be e.g. "www.google.com" or "123.456.123.978" or "FD...."
    // port can be e.g. "echo" or "7"
    // addressconfig guides if tcp or udp and if IPv4 or IPv6 or both should be used
    init (hostname : String, port : String, config : AddressConfig){
 
        call to resolveHostnameAndServiceToIPAddresses(...)
 
        store result in addressList
    }
 
    public func getAddressList() -> List<UnsafePointer<addinfo>>{
        ...
    }
 
 }
 
 
 */

// Brief:   Given given a hostname and a service this methods return a list of
//          IP and Port adresses that where obtained during the name resolution
//          e.g. "localhost" and "echo" as arguments will result in a list of 
//          IP addresses of the machine that runs the program and port set to 7
//
// socketConfig -   the provided SocketConfig object guides the name resolution
//                  the socketType_ and protocolType_ fields control which kind
//                  kind of socket you want to create.
//                  E.g. set them to .STREAM .TCP to obtain address for a TCP Stream socket
//              -   Set the addressFamily_ field to .UNSPECIFIED if you don't care if the
//                  name resolution leads to IPv4 or IPv6 addresses.
//
// hostname     -   e.g. "www.google.com" or "localhost"
// 
// service      -   can be a service string e.g. "echo" or a well-know port e.g. "7"

// Return Array of ResolvedInternetAddress

// Resolver guts
public func resolveHostnameAndServiceToIPAddresses(socketConfig : SocketConfig,
                                                   hostname : String,
                                                   service : String)throws
                                                    ->  UnsafeMutablePointer<addrinfo>
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
    var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
    
    let getaddrinfoReturnValue = getaddrinfo(hostname, service, &addressCriteria, &servinfo)
    guard getaddrinfoReturnValue == 0 else { throw Error(.IPAddressValidationFailed) }
    
    // Wrap linked list into array of ResolvedInternetAddress
    
    // Prevent memory leaks: getaddrinfo creates an unmanaged linked list on the heap
    // freeaddrinfo(servinfo)
    
    return servinfo
}

//Pointer casting

func sockaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}

func sockadd_list_cast(p: UnsafeMutablePointer<UnsafeMutablePointer<Int8>>) -> UnsafeMutablePointer<UnsafeMutablePointer<in_addr>> {
    return UnsafeMutablePointer<UnsafeMutablePointer<in_addr>>(p)
}

func sockaddr_storage_cast(p : UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}


