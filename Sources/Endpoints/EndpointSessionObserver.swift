import Foundation

public protocol EndpointServiceObserver: AnyObject {
    func service<E: EncodableEndpoint>(_ service: EndpointService, didEncode endpoint: E)
    func service<E: DecodableEndpoint>(_ service: EndpointService, didDecode endpoint: E)
    func service<E: Endpoint>(_ service: EndpointService, willBegin endpoint: E)
    func service<E: Endpoint>(_ service: EndpointService, didFinish endpoint: E, duration: TimeInterval)
    func service<E: Endpoint>(_ service: EndpointService, didFail endpoint: E, status code: Int, error: Error)
}

internal struct WeakBox {
    private(set) weak var object: EndpointServiceObserver? {
        didSet {
            guard object == nil else { return }
            onDeinit()
        }
    }

    var onDeinit: () -> Void
}

public final class EndpointPrintLogger: EndpointServiceObserver {
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    public init() { }

    public func service<E>(_ service: EndpointService, didEncode endpoint: E) where E: EncodableEndpoint {
        print("􀍠 [enc] \(endpoint.request.method.rawValue) \(endpoint.request.path) | \(E.Input.self)")
    }

    public func service<E>(_ service: EndpointService, didDecode endpoint: E) where E: DecodableEndpoint {
        print("􀍠 [dec] \(endpoint.request.method.rawValue) \(endpoint.request.path) | \(E.Output.self)")
    }

    public func service<E>(_ service: EndpointService, willBegin endpoint: E) where E: Endpoint {
        print("􀍠 [req] \(endpoint.request.method.rawValue) \(endpoint.request.path)")
    }

    public func service<E>(_ service: EndpointService, didFinish endpoint: E, duration: TimeInterval) where E: Endpoint {
        print("􀆅 [res] \(endpoint.request.method.rawValue) \(endpoint.request.path) (\(formatter.string(from: NSNumber(value: duration)) ?? "0")s)")
    }

    public func service<E>(_ service: EndpointService, didFail endpoint: E, status code: Int, error: Error) where E: Endpoint {
        print("􀅾 [res] \(endpoint.request.method.rawValue) \(endpoint.request.path) | \(code) \(error.localizedDescription)")
    }
}
