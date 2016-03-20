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
    case CloseSocketFailed
    
    case IPAddressValidationFailed
    case FailedToGetIPFromHostname(String)
    case UnparsableBytes
    
    case ConnectFailed
    case SendFailedToSendAllBytes
    case ReadFailed
    
    case Generic(String)
}

//see error codes: https://gist.github.com/gabrielfalcao/4216897
public struct Error: ErrorType, CustomStringConvertible {
    
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
