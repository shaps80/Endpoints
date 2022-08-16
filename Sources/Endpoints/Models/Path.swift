import Foundation

public struct Path: RawRepresentable {
    public var rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Path: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        rawValue = value
    }
}

extension Path: CustomStringConvertible {
    public var description: String { rawValue }
}
