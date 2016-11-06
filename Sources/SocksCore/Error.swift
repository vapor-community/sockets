//
//  SocksError.swift
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
    
    case createSocketFailed
    case optionSetFailed(level: Int32, name: Int32, value: String)
    case optionGetFailed(level: Int32, name: Int32, type: String)
    case closeSocketFailed
    
    case pipeCreationFailed
    
    case selectFailed(reads: [Descriptor], writes: [Descriptor], errors: [Descriptor])
    
    case localAddressResolutionFailed
    case remoteAddressResolutionFailed
    case ipAddressResolutionFailed
    case ipAddressValidationFailed
    case failedToGetIPFromHostname(String)
    case unparsableBytes
    
    case connectFailed
    case connectFailedWithSocketErrorCode(Int32)
    case connectTimedOut
    case sendFailedToSendAllBytes
    case readFailed
    case bindFailed
    case listenFailed
    case acceptFailed
    
    case unsupportedSocketAddressFamily(Int32)
    case concreteSocketAddressFamilyRequired
    
    case generic(String)
}

public struct SocksError: Error, CustomStringConvertible {
    
    public let type: ErrorReason
    public let number: Int32
    
    init(_ type: ErrorReason) {
        self.type = type
        self.number = errno //last reported error code
    }
    
    init(message: String) {
        self.type = .generic(message)
        self.number = -1
    }
    
    func getReason() -> String {
        guard number >= 0 else { return "?" }
        guard let reasonString = gai_strerror(number) else { return "?" }
        let reason = String(validatingUTF8: reasonString) ?? "?"
        return reason
    }
    
    public var description: String {
        return "Socket failed with code \(self.number) (\"\(ErrorLookUpTable.getCorrespondingErrorString(errorCode: self.number))\") [\(self.type)] \"\(getReason())\""
    }
}

public struct ErrorLookUpTable {
    
    public static func getCorrespondingErrorString(errorCode: Int32) -> String {
        return String(validatingUTF8: strerror(errorCode)) ?? "?"
    }
    
    public static let interruptedSystemCall: Int32 = EINTR
}
