import Foundation

/// Represents a domain that can process the associated endpoint's
public protocol Domain {
    /// A URL that represents the baseURL for this domain
    ///
    /// A fully defined `URLRequest` that represents this a request for the
    /// specified `Endpoint`. A default implementation exists so in most
    /// cases you do not need to implement this.
    func urlRequest<E: Endpoint>(for endpoint: E) async throws -> URLRequest
}
