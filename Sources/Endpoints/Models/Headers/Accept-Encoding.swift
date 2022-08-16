import Foundation

public extension AcceptEncoding {
    static let gzip: Self = "gzip"
    static let deflate: Self = "deflate"
    static let identity: Self = "identity"
}

public struct AccepEncodingHeaderKey: HeaderKey {
    public typealias Value = AcceptEncoding
    public static let name: String = "Accept-Encoding"
}

public extension Header {
    var acceptEncoding: AcceptEncoding? {
        get { self[AccepEncodingHeaderKey.self] }
        set { self[AccepEncodingHeaderKey.self] = newValue }
    }
}

public struct AcceptEncoding: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
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
