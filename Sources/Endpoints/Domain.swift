import Foundation

/// Represents a domain that can process the associated endpoint's
public protocol Domain {

    var urlSession: URLSession { get }

    func baseUrl<E: Endpoint>(for endpoint: E) async throws -> URL

    /// A URL that represents the baseURL for this domain
    ///
    /// A fully defined `URLRequest` that represents this a request for the
    /// specified `Endpoint`. A default implementation exists so in most
    /// cases you do not need to implement this.
    func urlRequest<E: Endpoint>(for endpoint: E) async throws -> URLRequest

    /// Returns the data and associated response returned from an API
    /// - Parameter request: The URL request that should request this data
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

public extension Domain {
    func urlRequest<E: Endpoint>(for endpoint: E) async throws -> URLRequest {
        try await endpoint.urlRequest(baseUrl: baseUrl(for: endpoint))
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15, *) {
            return try await urlSession.data(for: request)
        } else {
            return try await urlSession.backport.data(for: request)
        }
    }
}
