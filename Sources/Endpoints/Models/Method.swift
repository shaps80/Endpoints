import Foundation

public extension Method {
    static var get: Self = "GET"
    static var post: Self = "POST"
    static var put: Self = "PUT"
    static var patch: Self = "PATCH"
    static var update: Self = "UPDATE"
    static var delete: Self = "DELETE"
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
