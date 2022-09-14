import Foundation
import Combine

/// Represents an endpoint where data may be sent to an associated `Domain`.
///
/// If you also expect response data from this endpoint, you can conform your type
/// to both `CodableEndpoint` instead.
public protocol EncodableEndpoint: Endpoint {
    /// The expected `Encodable` type
    associatedtype Input: Encodable
    /// The encoder type that can encode the http body
    associatedtype Encoder: TopLevelEncoder where Encoder.Output == Data
    /// The top level encoder that can encode data to the specified input
    var encoder: Encoder { get }
    /// The HTTP body that will be encoded for the request
    var body: Input { get }
    /// Encodes the `body` into `Data`. A default implementation is provided
    /// however you can override this to provide a custom implementation.
    func encode() throws -> Data
}

public extension EncodableEndpoint {
    var encoder: JSONEncoder { .init() }
    func encode() throws -> Data {
        try encoder.encode(body)
    }
}
