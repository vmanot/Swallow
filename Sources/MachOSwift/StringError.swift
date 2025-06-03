public struct StringError: RawRepresentable, Error, CustomStringConvertible, ExpressibleByStringLiteral {
    public let rawValue: String
    public var description: String { rawValue }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(format: String, _ arguments: any CVarArg...) {
        self.rawValue = String(format: format, arguments: arguments)
    }
}
