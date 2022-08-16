import Foundation

public extension ContentType {
    static let text: Self = "text/plain"
    static let xml: Self = "application/xml"
    static let json: Self = "application/json"
    static var urlEncoded: Self = "application/x-www-form-urlencoded"
}

public struct ContentTypeKey: HeaderKey {
    public typealias Value = ContentType
    public static let name: String = "Content-Type"
}

public extension Header {
    var contentType: ContentType? {
        get { self[ContentTypeKey.self] }
        set { self[ContentTypeKey.self] = newValue }
    }
}

public struct ContentType: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
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
