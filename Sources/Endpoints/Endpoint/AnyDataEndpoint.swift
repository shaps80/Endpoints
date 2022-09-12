import Foundation

/// An internal type for performing low-level data-only requests
public struct AnyDataEndpoint: Endpoint {
    public var method: Method
    public var request: Request

    public init<E: Endpoint>(_ endpoint: E) {
        self.method = endpoint.method
        self.request = endpoint.request
    }
}
