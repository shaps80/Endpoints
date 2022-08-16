import Foundation

public struct UserAgentHeaderKey: HeaderKey {
    public typealias Value = UserAgentValue
    public static let name: String = "User-Agent"
}

public extension Header {
    var userAgent: UserAgentValue? {
        get { self[UserAgentHeaderKey.self] }
        set { self[UserAgentHeaderKey.self] = newValue }
    }
}

public struct UserAgentValue: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
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
