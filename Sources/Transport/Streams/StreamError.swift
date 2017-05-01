/// Errors that may be thrown when interacting
/// with streams.
public enum StreamError {
    case closed
}

extension StreamError: Debuggable {
    public var reason: String {
        switch self {
        case .closed:
            return "The stream is closed"
        }
    }
    
    public var identifier: String {
        switch self {
        case .closed:
            return "closed"
        }
    }
    
    public var possibleCauses: [String] {
        return []
    }
    
    public var suggestedFixes: [String] {
        return []
    }
}
