//
//  Error.swift
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

public enum ErrorReason {
    
    case CreateSocketFailed
    case ReuseAddressSetFailed
    case CloseSocketFailed
    
    case IPAddressValidationFailed
    case FailedToGetIPFromHostname(String)
    case UnparsableBytes
    
    case ConnectFailed
    case SendFailedToSendAllBytes
    case ReadFailed
    case BindFailed
    case ListenFailed
    case AcceptFailed
    
    case UnsupportedSocketAddressFamily(Int32)
    case ConcreteSocketAddressFamilyRequired
    
    case IPAddressResolutionFailed
    
    case Generic(String)
}

//see error codes: https://gist.github.com/czechboy0/517b22041c0eeb33f723bb66933882e4
public struct Error: ErrorProtocol, CustomStringConvertible {
    
    public let type: ErrorReason
    public let number: Int32
    
    init(_ type: ErrorReason) {
        self.type = type
        self.number = errno //last reported error code
    }
    
    init(_ message: String) {
        self.type = .Generic(message)
        self.number = -1
    }
    
    public var description: String {
        return "Socket failed with code \(self.number) [\(self.type)]"
    }
}
