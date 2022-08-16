import Foundation
import Combine

/// Represents an endpoint where data is returned from an associated `Domain`.
///
/// If you also expect to send data, you can conform your type
/// to `CodableEndpoint` instead.
public protocol DecodableEndpoint: Endpoint {
    /// The expected `Decodable` type
    associatedtype Output: Decodable
    /// The decoder type that can decode the response data
    associatedtype Decoder: TopLevelDecoder where Decoder.Input == Data
    /// The top level encoder that can decode data to the specified output
    var decoder: Decoder { get }
    /// Decodes `data` into `Result`. A default implementation is provided
    /// however you can override this to provide a custom implementation.
    func decode(_ data: Data) throws -> Output
}

public extension DecodableEndpoint {
    var decoder: JSONDecoder { .init() }
    func decode(_ data: Data) throws -> Output {
        try decoder.decode(Output.self, from: data)
    }
}
