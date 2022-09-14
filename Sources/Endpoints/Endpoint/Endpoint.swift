import Foundation
import ImageIO

public typealias CodableEndpoint = EncodableEndpoint & DecodableEndpoint

/// Represents a simple Endpoint. Generally you don't use this directly,
/// rather you should conform to `DecodableEndpoint`, `EncodableEndpoint` or both.
public protocol Endpoint {
    /// The path associated with this endpoint
    ///
    /// - Note: This value will be appended to the `URL` provided by `Domain`
    var request: Request { get }
}

public extension Endpoint {
    func urlRequest(baseUrl: URL) throws -> URLRequest {
        let url = baseUrl

        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            throw EndpointError.badEndpoint("Unable to construct URL from endpoint: \(self) – baseURL: \(url)")
        }

        let queries = request.queries
            .filter { $0.value != nil }
            .compactMap { $0.queryItem }

        var items = components.queryItems ?? []
        items.append(contentsOf: queries)
        if !items.isEmpty { components.queryItems = items }

        guard let url = components.url?.appendingPathComponent(request.path) else {
            throw EndpointError.badEndpoint("Unable to construct URL from endpoint: \(self) – baseURL: \(url)")
        }

        var urlRequest = URLRequest(
            url: url,
            cachePolicy: request.cachePolicy,
            timeoutInterval: request.timeout
        )

        let headers = request.headers
            .map { ($0.name, $0.value?.description) }

        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = Dictionary(headers) { h1, _ in h1 }.compactMapValues { $0 }
        urlRequest.allowsCellularAccess = request.allowsCellularAccess
        urlRequest.allowsExpensiveNetworkAccess = request.allowsExpensiveNetworkAccess
        urlRequest.allowsConstrainedNetworkAccess = request.allowsConstrainedNetworkAccess

        return urlRequest
    }
}
