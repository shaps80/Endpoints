import Foundation

/// Represents a session for an EndpointService
///
/// Typically this wraps the `shared` URLSession instance. However you
/// can provide a custom session (useful in testing) as well.
public protocol EndpointSession {
    var urlSession: URLSession { get }
    /// Returns the data and associated response returned from an API
    /// - Parameter request: The URL request that should request this data
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Represents a service that can perform requests against `domains` and their associated `endpoints`
public final class EndpointService {
    let session: EndpointSession
    private var observers: [ObjectIdentifier: WeakBox] = [:]

    /// Creates a new service with the specified session
    /// - Parameter session: The session that will process endpoint requests
    public init(session: EndpointSession? = nil, observers: [EndpointServiceObserver] = [EndpointPrintLogger()]) {
        self.session = session ?? Session()
        observers.forEach { register($0) }
    }

    public func register(_ observer: EndpointServiceObserver) {
        observers[ObjectIdentifier(observer)] = .init(object: observer) { [weak self] in
            self?.unregister(observer)
        }
    }

    public func unregister(_ observer: EndpointServiceObserver) {
        observers[ObjectIdentifier(observer)] = nil
    }
}

public extension EndpointService {
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> HTTPURLResponse where E: Endpoint {
        try await perform(endpoint, from: domain, data: nil).1
    }
}

// MARK: Codable

public extension EndpointService {
    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    ///   - body: The encodable body to include in the URLRequest
    /// - Returns: The decoded data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (E.Output, HTTPURLResponse)
    where E: DecodableEndpoint & EncodableEndpoint
    {
        let encoded = try encode(endpoint: endpoint, for: domain)
        let result = try await perform(endpoint, from: domain, data: encoded)
        return (try decode(result.0, endpoint: endpoint, for: domain), result.1)
    }

    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    ///   - body: The encodable body to include in the URLRequest
    /// - Returns: The data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (E.Output, HTTPURLResponse)
    where E: DecodableEndpoint & EncodableEndpoint, E.Output == Data
    {
        let encoded = try encode(endpoint: endpoint, for: domain)
        return try await perform(endpoint, from: domain, data: encoded)
    }

    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    ///   - body: The body data to include in the URLRequest
    /// - Returns: The decoded data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (E.Output, HTTPURLResponse)
    where E: DecodableEndpoint & EncodableEndpoint, E.Input == Data
    {
        let result = try await perform(endpoint, from: domain, data: endpoint.body)
        return (try decode(result.0, endpoint: endpoint, for: domain), result.1)
    }

    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    ///   - body: The body data to include in the URLRequest
    /// - Returns: The data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (E.Output, HTTPURLResponse)
    where E: DecodableEndpoint & EncodableEndpoint, E.Input == Data, E.Output == Data
    {
        try await perform(endpoint, from: domain, data: endpoint.body)
    }
}

// MARK: Decodable

public extension EndpointService {
    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    /// - Returns: The data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (E.Output, HTTPURLResponse)
    where E: DecodableEndpoint, E.Output == Data
    {
        try await perform(endpoint, from: domain, data: nil)
    }

    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    /// - Returns: The decoded data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (E.Output, HTTPURLResponse)
    where E: DecodableEndpoint
    {
        let dataEndpoint = AnyDataEndpoint(endpoint)
        let (data, response) = try await perform(dataEndpoint, from: domain, data: nil)
        return (try decode(data, endpoint: endpoint, for: domain), response)
    }
}

// MARK: Encodable

public extension EndpointService {
    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    ///   - body: The body data to include in the URLRequest
    /// - Returns: The data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (Data, HTTPURLResponse)
    where E: EncodableEndpoint, E.Input == Data
    {
        try await perform(endpoint, from: domain, data: endpoint.body)
    }

    /// Performs a request for the specified `endpoint`
    /// - Parameters:
    ///   - endpoint: The `endpoint` configuration
    ///   - domain: The `domain` associated with this endpoint
    ///   - body: The encodable body to include in the URLRequest
    /// - Returns: The data and response returned for this endpoint request
    func perform<E>(_ endpoint: E, from domain: Domain) async throws -> (Data, HTTPURLResponse)
    where E: EncodableEndpoint
    {
        let encoded = try encode(endpoint: endpoint, for: domain)
        return try await perform(endpoint, from: domain, data: encoded)
    }
}

// MARK: Private

private extension EndpointService {
    func encode<E: EncodableEndpoint>(endpoint: E, for domain: Domain) throws -> Data {
        do {
            let result = try endpoint.encode()
            observers.values.forEach {
                $0.object?.service(self, didEncode: endpoint, for: domain)
            }
            return result
        } catch let EncodingError.invalidValue(_, context) {
            try throwError(error: EndpointError.encoding(E.Input.self, context), status: -1, endpoint: endpoint, for: domain)
        } catch {
            try throwError(error: error, status: -1, endpoint: endpoint, for: domain)
        }
    }

    func decode<E: DecodableEndpoint>(_ data: Data, endpoint: E, for domain: Domain) throws -> E.Output {
        do {
            let result = try endpoint.decode(data)
            observers.values.forEach {
                $0.object?.service(self, didDecode: endpoint, for: domain)
            }
            return result
        } catch let DecodingError.dataCorrupted(context) {
            try throwError(error: EndpointError.decoding(E.Output.self, context), status: -1, endpoint: endpoint, for: domain)
        } catch let DecodingError.valueNotFound(_, context) {
            try throwError(error: EndpointError.decoding(E.Output.self, context), status: -1, endpoint: endpoint, for: domain)
        } catch let DecodingError.typeMismatch(_, context) {
            try throwError(error: EndpointError.decoding(E.Output.self, context), status: -1, endpoint: endpoint, for: domain)
        } catch let DecodingError.keyNotFound(_, context) {
            try throwError(error: EndpointError.decoding(E.Output.self, context), status: -1, endpoint: endpoint, for: domain)
        } catch {
            try throwError(error: error, status: -1, endpoint: endpoint, for: domain)
        }
    }

    func throwError<E: Endpoint>(error: Error, status: Int, endpoint: E, for domain: Domain) throws -> Never {
        observers.values.forEach {
            $0.object?.service(self, didFail: endpoint, for: domain, status: status, error: error)
        }
        throw error
    }

    func perform<E: Endpoint>(_ endpoint: E, from domain: Domain, data: Data?) async throws -> (Data, HTTPURLResponse) {
        let start = Date()
        var request = try await domain.urlRequest(for: endpoint)
        request.httpBody = data

        observers.values.forEach {
            $0.object?.service(self, willBegin: endpoint, for: domain)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            try throwError(error: EndpointError.unexpectedResponse(response), status: -1, endpoint: endpoint, for: domain)
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            try throwError(error: EndpointError.badResponse(httpResponse), status: httpResponse.statusCode, endpoint: endpoint, for: domain)
        }

        let end = Date()
        let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        observers.values.forEach {
            $0.object?.service(self, didFinish: endpoint, for: domain, duration: duration)
        }

        return (data, httpResponse)
    }
}

/// Represents the various errors that can be thrown from an `EndpointService`
public enum EndpointError: LocalizedError {
    /// A URL could not be constructed from an associated `Endpoint`
    case badEndpoint(String)
    /// The response was unexpected, likely not an `HTTPURLResponse`
    case unexpectedResponse(URLResponse)
    /// The response did not return a success `statusCode`
    case badResponse(HTTPURLResponse)
    /// The body data could not be encoded
    case encoding(Any.Type, EncodingError.Context)
    /// The data could not be decoded
    case decoding(Any.Type, DecodingError.Context)

    public var errorDescription: String? {
        switch self {
        case let .badEndpoint(message):
            return message
        case let .unexpectedResponse(response):
            return "Unexpected response: \(response)"
        case let .badResponse(response):
            switch response.statusCode {
            case 401:
                return "Authentication Required"
            case 404:
                return "Resource not found"
            default:
                return "Bad response: \(response)"
            }
        case let .encoding(type, context):
            return "\(String(describing: type)) – \(context.debugDescription)"
        case let .decoding(type, context):
            let path = context.codingPath
                .map(\.stringValue)
                .joined(separator: ".")
            return "\(String(describing: type)).\(path) – \(context.debugDescription)"
        }
    }
}

private final class Session: EndpointSession {
    var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15, *) {
            return try await urlSession.data(for: request)
        } else {
            return try await urlSession.backport.data(for: request)
        }
    }
}
