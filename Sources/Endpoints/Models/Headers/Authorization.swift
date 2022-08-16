import Foundation

extension AnyAuthorizationScheme {
    public static func basic(username: String, password: String) -> Self {
        .init(BasicAuthorizationScheme(username: username, password: password))
    }

    public static func bearer(token: String) -> Self {
        .init(BearerAuthorizationScheme(token: token))
    }
}

public struct AnyAuthorizationScheme: CustomStringConvertible {
    public let description: String
    public init<S: AuthorizationScheme>(_ scheme: S) {
        description = scheme.description
    }
}

public struct AuthorizationHeaderKey: HeaderKey {
    public typealias Value = AnyAuthorizationScheme
    public static let name: String = "Authorization"
}

public extension Header {
    var authorization: AnyAuthorizationScheme? {
        get { self[AuthorizationHeaderKey.self] }
        set { self[AuthorizationHeaderKey.self] = newValue }
    }
}

public protocol AuthorizationScheme: CustomStringConvertible { }

private struct BasicAuthorizationScheme: AuthorizationScheme {
    let username: String
    let password: String

    var description: String {
        let encoded = Data(base64Encoded: "\(username):\(password)") ?? .init()
        return "Basic \(encoded.base64EncodedString())"
    }
}

private struct BearerAuthorizationScheme: AuthorizationScheme {
    let token: String

    var description: String {
        return "Bearer \(token)"
    }
}
