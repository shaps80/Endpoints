import Foundation

public extension Method {
    static var GET: Self = "GET"
    static var POST: Self = "POST"
    static var PUT: Self = "PUT"
    static var PATCH: Self = "PATCH"
    static var UPDATE: Self = "UPDATE"
    static var DELETE: Self = "DELETE"
}

public struct Method: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Method: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        rawValue = value
    }
}

extension Method: CustomStringConvertible {
    public var description: String { rawValue }
}
