import Foundation

public struct Request {
    public var path: String
    public var queries: [Query] = []
    public var headers: [Header] = [
        Header(\.contentType, value: .json),
        Header(\.accept, value: .json)
    ]

    /// The cache policy to apply to this endpoint
    var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

    /// The timeout to apply to this endpoint
    var timeout: TimeInterval = 60

    /// If true, the request may still be performed even if only a cellular interface is available. Defaults to `true`
    ///
    /// - Note: This setting also depends on n appropriate `URLSessionConfiguration`.
    var allowsCellularAccess: Bool = true

    /// If true, the request may still be performed even if there are no non-expensive interfaces available (e.g. Hot-spot). Defaults to `true`
    ///
    /// - Note: This setting also depends on n appropriate `URLSessionConfiguration`.
    var allowsExpensiveNetworkAccess: Bool = true

    /// If true, the request may still be performed even if the user has specified Low Data Mode. Defaults to `true`
    ///
    /// - Note: This setting also depends on n appropriate `URLSessionConfiguration`.
    var allowsConstrainedNetworkAccess: Bool = true
}

public extension Request {
    init(path: String) {
        self.path = path
    }

    init(path: String, @QueryBuilder queries: () -> [Query]) {
        self.path = path
        self.queries = queries()
    }

    init(path: String, @HeadersBuilder headers: () -> [Header]) {
        self.path = path
        self.headers = headers()
    }

    init(path: String, @QueryBuilder queries: () -> [Query], @HeadersBuilder headers: () -> [Header]) {
        self.path = path
        self.queries = queries()
        self.headers = headers()
    }
}

public extension Request {
    func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        var copy = self
        copy.cachePolicy = policy
        return copy
    }

    func timeout(_ timeout: TimeInterval) -> Self {
        var copy = self
        copy.timeout = timeout
        return copy
    }

    func allowsCellularAccess(_ allowed: Bool) -> Self {
        var copy = self
        copy.allowsCellularAccess = allowed
        return copy
    }

    func allowsExpensiveNetworkAccess(_ allowed: Bool) -> Self {
        var copy = self
        copy.allowsExpensiveNetworkAccess = allowed
        return copy
    }

    func allowsConstrainedNetworkAccess(_ allowed: Bool) -> Self {
        var copy = self
        copy.allowsConstrainedNetworkAccess = allowed
        return copy
    }
}
