import Foundation

public extension AcceptValue {
    static let html: Self = "text/html"
    static let xhtml: Self = "application/xhtml"
    static let xml: Self = "application/xml"
    static let json: Self = "application/json"
}

public struct AccepHeaderKey: HeaderKey {
    public typealias Value = AcceptValue
    public static let name: String = "Accept"
}

public extension Header {
    var accept: AcceptValue? {
        get { self[AccepHeaderKey.self] }
        set { self[AccepHeaderKey.self] = newValue }
    }
}

public struct AcceptValue: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        rawValue = value
    }

    public var description: String {
        rawValue
    }
}
