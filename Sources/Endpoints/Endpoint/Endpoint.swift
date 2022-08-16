import Foundation
import ImageIO

public typealias CodableEndpoint = EncodableEndpoint & DecodableEndpoint

/// Represents a simple Endpoint. Generally you don't use this directly,
/// rather you should conform to `DecodableEndpoint`, `EncodableEndpoint` or both.
public protocol Endpoint {
    /// The HTTP method to apply to this endpoint.
    /// Defaults to `.get` for `DecodableEndpoint` and `.post` for `EncodableEndpoint` types.
    var method: Method { get }

    /// The path associated with this endpoint
    ///
    /// - Note: This value will be appended to the `URL` provided by `Domain`
    var path: Path { get }

    /// The query items to apply to this endpoint
    @QueryBuilder var queries: Queries { get }

    /// The HTTP headers to apply to this endpoint
    @HeadersBuilder var headers: Headers { get }

    /// The cache policy to apply to this endpoint
    var cachePolicy: URLRequest.CachePolicy { get }

    /// The timeout to apply to this endpoint
    var timeout: TimeInterval { get }

    /// If true, the request may still be performed even if only a cellular interface is available. Defaults to `true`
    ///
    /// - Note: This setting also depends on n appropriate `URLSessionConfiguration`.
    var allowsCellularAccess: Bool { get }

    /// If true, the request may still be performed even if there are no non-expensive interfaces available (e.g. Hot-spot). Defaults to `true`
    ///
    /// - Note: This setting also depends on n appropriate `URLSessionConfiguration`.
    var allowsExpensiveNetworkAccess: Bool { get }

    /// If true, the request may still be performed even if the user has specified Low Data Mode. Defaults to `true`
    ///
    /// - Note: This setting also depends on n appropriate `URLSessionConfiguration`.
    var allowsConstrainedNetworkAccess: Bool { get }

}

public extension Endpoint {
    @QueryBuilder var queries: Queries { EmptyQuery() }
    @HeadersBuilder var headers: Headers {
        Header(\.contentType, value: .json)
        Header(\.accept, value: .json)
    }

    var method: Method { .GET }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var timeout: TimeInterval { 60 }
    var allowsCellularAccess: Bool { true }
    var allowsExpensiveNetworkAccess: Bool { true }
    var allowsConstrainedNetworkAccess: Bool { true }
}

public extension Endpoint {
    func request(baseUrl: URL) throws -> URLRequest {
        let url = baseUrl

        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            throw EndpointError.badEndpoint("Unable to construct URL from endpoint: \(self) – baseURL: \(url)")
        }

        let queries = queries.queries
            .filter { $0.value != nil }
            .map { URLQueryItem(name: $0.name, value: $0.value!.description) }

        var items = components.queryItems ?? []
        items.append(contentsOf: queries)
        if !items.isEmpty { components.queryItems = items }

        guard let url = components.url?.appendingPathComponent(path.rawValue) else {
            throw EndpointError.badEndpoint("Unable to construct URL from endpoint: \(self) – baseURL: \(url)")
        }

        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy,
            timeoutInterval: timeout
        )

        let headers = headers.headers
            .map { ($0.name, $0.value?.description) }

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = Dictionary(headers) { h1, _ in h1 }.compactMapValues { $0 }
        request.allowsCellularAccess = allowsCellularAccess
        request.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        request.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess

        return request
    }
}
