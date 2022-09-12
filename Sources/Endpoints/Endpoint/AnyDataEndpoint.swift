import Foundation

/// An internal type for performing low-level data-only requests
public struct AnyDataEndpoint: Endpoint {
    public var method: Method
    public var request: Request
    public var queries: [Query]
    public var headers: [Header]
    public var cachePolicy: URLRequest.CachePolicy
    public var timeout: TimeInterval
    public var allowsCellularAccess: Bool
    public var allowsExpensiveNetworkAccess: Bool
    public var allowsConstrainedNetworkAccess: Bool

    public init<E: Endpoint>(_ endpoint: E) {
        self.method = endpoint.method
        self.request = endpoint.request
        self.queries = endpoint.request.queries
        self.headers = endpoint.request.headers
        self.cachePolicy = endpoint.cachePolicy
        self.timeout = endpoint.timeout
        self.allowsCellularAccess = endpoint.allowsCellularAccess
        self.allowsExpensiveNetworkAccess = endpoint.allowsExpensiveNetworkAccess
        self.allowsConstrainedNetworkAccess = endpoint.allowsConstrainedNetworkAccess
    }
}
