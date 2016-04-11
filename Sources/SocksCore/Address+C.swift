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
    addressCriteria.ai_family = socketConfig.addressFamily_.toCType()
    addressCriteria.ai_flags = AI_PASSIVE
    // Restricting to TCP
    addressCriteria.ai_socktype = socketConfig.socketType_.toCType()
    addressCriteria.ai_protocol = socketConfig.protocolType_.toCType()
    
    // The list of addresses that correspond to the hostname/service pair.
    var servinfo = UnsafeMutablePointer<socket_addrinfo>.init(nil)
    
    let getaddrinfoReturnValue = getaddrinfo(hostname, service, &addressCriteria, &servinfo)
    guard getaddrinfoReturnValue == 0 else { throw Error(.IPAddressValidationFailed) }
    
    return servinfo
}

//Pointer casting

func sockaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}

func sockadd_list_cast(p: UnsafeMutablePointer<UnsafeMutablePointer<Int8>>) -> UnsafeMutablePointer<UnsafeMutablePointer<in_addr>> {
    return UnsafeMutablePointer<UnsafeMutablePointer<in_addr>>(p)
}


