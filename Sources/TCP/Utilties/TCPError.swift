import Debugging
import COperatingSystem

/// Errors that can be thrown while working with TCP sockets.
public struct TCPError: Debuggable {
    public static let readableName = "TCP Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var possibleCauses: [String]
    public var suggestedFixes: [String]

    /// Create a new TCP error.
    public init(
        identifier: String,
        reason: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        source: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = TCPError.makeStackTrace()
        self.possibleCauses = possibleCauses
        self.suggestedFixes = suggestedFixes
    }
    
    /// Create a new TCP error from a POSIX errno.
    static func posix(
        _ errno: Int32,
        identifier: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        source: SourceLocation
    ) -> TCPError {
        let message = COperatingSystem.strerror(errno)
        let string = String(cString: message!, encoding: .utf8) ?? "unknown"
        return TCPError(
            identifier: identifier,
            reason: string,
            possibleCauses: possibleCauses,
            suggestedFixes: suggestedFixes,
            source: source
        )
    }
}

func ERROR(_ message: String, file: StaticString = #file, line: Int = #line) {
    print("[TCP] \(message) [\(file.description.split(separator: "/").last!):\(line)]")
}

/// For printing debug info.
func DEBUG(_ string: @autoclosure () -> String, file: StaticString = #file, line: Int = #line) {
    #if VERBOSE
    print("[VERBOSE] \(string()) [\(file.description.split(separator: "/").last!):\(line)]")
    #endif
}
