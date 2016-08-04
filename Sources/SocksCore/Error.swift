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

//see error codes: https://gist.github.com/czechboy0/517b22041c0eeb33f723bb66933882e4

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
        return "Socket failed with code \(self.number) (\"\(ErrorLookUpTable.getCorrespondingErrorString(errorCode: Int(self.number)))\") [\(self.type)] \"\(getReason())\""
    }
}

public struct ErrorLookUpTable {
    
    public static func getCorrespondingErrorString(errorCode: Int) -> String {
        guard let description = errorDescriptions[errorCode] else { return "?" }
        return description
    }
    
    static let errorDescriptions = [
        0: "Success",
        1: "Operation not permitted",
        2: "No such file or directory",
        3: "No such process",
        4: "Interrupted system call",
        5: "Input/output error",
        6: "No such device or address",
        7: "Argument list too long",
        8: "Exec format error",
        9: "Bad file descriptor",
        10: "No child processes",
        11: "Resource temporarily unavailable",
        12: "Cannot allocate memory",
        13: "Permission denied",
        14: "Bad address",
        15: "Block device required",
        16: "Device or resource busy",
        17: "File exists",
        18: "Invalid cross-device link",
        19: "No such device",
        20: "Not a directory",
        21: "Is a directory",
        22: "Invalid argument",
        23: "Too many open files in system",
        24: "Too many open files",
        25: "Inappropriate ioctl for device",
        26: "Text file busy",
        27: "File too large",
        28: "No space left on device",
        29: "Illegal seek",
        30: "Read-only file system",
        31: "Too many links",
        32: "Broken pipe",
        33: "Numerical argument out of domain",
        34: "Numerical result out of range",
        35: "Resource deadlock avoided",
        36: "File name too long",
        37: "No locks available",
        38: "Function not implemented",
        39: "Directory not empty",
        40: "Too many levels of symbolic links",
        41: "Unknown error 41",
        42: "No message of desired type",
        43: "Identifier removed",
        44: "Channel number out of range",
        45: "Level 2 not synchronized",
        46: "Level 3 halted",
        47: "Level 3 reset",
        48: "Link number out of range",
        49: "Protocol driver not attached",
        50: "No CSI structure available",
        51: "Level 2 halted",
        52: "Invalid exchange",
        53: "Invalid request descriptor",
        54: "Exchange full",
        55: "No anode",
        56: "Invalid request code",
        57: "Invalid slot",
        58: "Unknown error 58",
        59: "Bad font file format",
        60: "Device not a stream",
        61: "No data available",
        62: "Timer expired",
        63: "Out of streams resources",
        64: "Machine is not on the network",
        65: "Package not installed",
        66: "Object is remote",
        67: "Link has been severed",
        68: "Advertise error",
        69: "Srmount error",
        70: "Communication error on send",
        71: "Protocol error",
        72: "Multihop attempted",
        73: "RFS specific error",
        74: "Bad message",
        75: "Value too large for defined data type",
        76: "Name not unique on network",
        77: "File descriptor in bad state",
        78: "Remote address changed",
        79: "Can not access a needed shared library",
        80: "Accessing a corrupted shared library",
        81: ".lib section in a.out corrupted",
        82: "Attempting to link in too many shared libraries",
        83: "Cannot exec a shared library directly",
        84: "Invalid or incomplete multibyte or wide character",
        85: "Interrupted system call should be restarted",
        86: "Streams pipe error",
        87: "Too many users",
        88: "Socket operation on non-socket",
        89: "Destination address required",
        90: "Message too long",
        91: "Protocol wrong type for socket",
        92: "Protocol not available",
        93: "Protocol not supported",
        94: "Socket type not supported",
        95: "Operation not supported",
        96: "Protocol family not supported",
        97: "Address family not supported by protocol",
        98: "Address already in use",
        99: "Cannot assign requested address",
        100: "Network is down",
        101: "Network is unreachable",
        102: "Network dropped connection on reset",
        103: "Software caused connection abort",
        104: "Connection reset by peer",
        105: "No buffer space available",
        106: "Transport endpoint is already connected",
        107: "Transport endpoint is not connected",
        108: "Cannot send after transport endpoint shutdown",
        109: "Too many references: cannot splice",
        110: "Connection timed out",
        111: "Connection refused",
        112: "Host is down",
        113: "No route to host",
        114: "Operation already in progress",
        115: "Operation now in progress",
        116: "Stale NFS file handle",
        117: "Structure needs cleaning",
        118: "Not a XENIX named type file",
        119: "No XENIX semaphores available",
        120: "Is a named type file",
        121: "Remote I/O error",
        122: "Disk quota exceeded",
        123: "No medium found",
        124: "Wrong medium type"]
    
}
