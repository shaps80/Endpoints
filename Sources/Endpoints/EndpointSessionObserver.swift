import Foundation

public protocol EndpointServiceObserver: AnyObject {
    func service<E: EncodableEndpoint>(_ service: EndpointService, didEncode endpoint: E, for domain: Domain)
    func service<E: DecodableEndpoint>(_ service: EndpointService, didDecode endpoint: E, for domain: Domain)
    func service<E: Endpoint>(_ service: EndpointService, willBegin endpoint: E, for domain: Domain)
    func service<E: Endpoint>(_ service: EndpointService, didFinish endpoint: E, for domain: Domain, duration: TimeInterval)
    func service<E: Endpoint>(_ service: EndpointService, didFail endpoint: E, for domain: Domain, status code: Int, error: Error)
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

    public func service<E>(_ service: EndpointService, didEncode endpoint: E, for domain: Domain) where E: EncodableEndpoint {
        print("􀍠 [enc] \(endpoint.method.rawValue) \(endpoint.request.path) | \(E.Input.self)")
    }

    public func service<E>(_ service: EndpointService, didDecode endpoint: E, for domain: Domain) where E: DecodableEndpoint {
        print("􀍠 [dec] \(endpoint.method.rawValue) \(endpoint.request.path) | \(E.Output.self)")
    }

    public func service<E>(_ service: EndpointService, willBegin endpoint: E, for domain: Domain) where E: Endpoint {
        print("􀍠 [req] \(endpoint.method.rawValue) \(endpoint.request.path)")
    }

    public func service<E>(_ service: EndpointService, didFinish endpoint: E, for domain: Domain, duration: TimeInterval) where E: Endpoint {
        print("􀆅 [res] \(endpoint.method.rawValue) \(endpoint.request.path) (\(formatter.string(from: NSNumber(value: duration)) ?? "0")s)")
    }

    public func service<E>(_ service: EndpointService, didFail endpoint: E, for domain: Domain, status code: Int, error: Error) where E: Endpoint {
        print("􀅾 [res] \(endpoint.method.rawValue) \(endpoint.request.path) | \(code) \(error.localizedDescription)")
    }
}
