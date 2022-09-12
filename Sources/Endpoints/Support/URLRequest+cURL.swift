import Foundation

extension URLRequest {
    /// Returns a cURL command representation of this URL request. Useful for debugging.
    public var curl: Curl { Curl(self) }
}

/// Returns a cURL representation, useful for debugging
public struct Curl: CustomStringConvertible, CustomDebugStringConvertible {

    /// The fully formed request this represents
    public let request: URLRequest

    /// The name of the request, defaults to `url.path`
    public let name: String

    public init<E: Endpoint>(_ endpoint: E, domain: Domain) async throws {
        let request = try await domain.urlRequest(for: endpoint)
        self.init(request)
    }

    public init(_ request: URLRequest) {
        self.request = request
        name = request.url?.path ?? "\(request.hashValue)"
    }

    public var description: String {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? "/"
        return "\(method) \(path)"
    }

    public var debugDescription: String {
        return components.joined(separator: " \\\n\t")
    }

    private var components: [String] {
        guard let url = request.url else { return [] }
        var base = #"curl "\#(url.absoluteString)""#

        if request.httpMethod == "HEAD" {
            base += " --head"
        }

        var components = [base]

        if let method = request.httpMethod {
            components.append("-X \(method)")
        }

        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                components.append("-H '\(key): \(value)'")
            }
        }

        if let data = request.httpBody, let body = String(data: data, encoding: .utf8) {
            components.append("-d '\(body)'")
        }

        return components
    }

}
