//
//  Address+C.swift
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

//Pointer casting

func sockaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutablePointer<sockaddr>(p)
}

func sockadd_list_cast(p: UnsafeMutablePointer<UnsafeMutablePointer<Int8>>) -> UnsafeMutablePointer<UnsafeMutablePointer<in_addr>> {
    return UnsafeMutablePointer<UnsafeMutablePointer<in_addr>>(p)
}


