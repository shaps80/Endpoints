import Foundation

public protocol HeaderKey {
    associatedtype Value: CustomStringConvertible
    static var name: String { get }
}

public struct Header {
    var name: String = ""
    var value: CustomStringConvertible?

    public init(name: String, value: CustomStringConvertible?) {
        self.name = name
        self.value = value
    }

    public init<T: RawRepresentable>(name: String, value: T) where T.RawValue: CustomStringConvertible {
        self.name = name
        self.value = value.rawValue
    }

    public init<V>(_ keyPath: WritableKeyPath<Header, V>, value: V) {
        self[keyPath: keyPath] = value
    }

    public subscript<K>(key: K.Type) -> K.Value? where K: HeaderKey {
        get { nil }
        set {
            self.name = K.name
            self.value = newValue
        }
    }
}

public protocol Headers {
    var headers: [Header] { get }
}

extension Header: Headers {
    public var headers: [Header] {
        [.init(name: name, value: value)]
    }
}

extension Array: Headers where Element == Header {
    public var headers: [Element] { self }
}

public struct EmptyHeader: Headers {
    public var headers: [Header] { [] }
    public init() { }
}

@resultBuilder
public struct HeadersBuilder {
    public static func buildBlock(_ components: Headers...) -> Headers {
        components.flatMap { $0.headers }
    }

    public static func buildOptional(_ component: Headers?) -> Headers {
        component ?? []
    }

    public static func buildEither(first component: Headers) -> Headers {
        component
    }

    public static func buildEither(second component: Headers) -> Headers {
        component
    }

    public static func buildArray(_ components: [Headers]) -> Headers {
        components.flatMap { $0.headers }
    }

    public static func buildLimitedAvailability(_ component: Headers) -> Headers {
        component
    }
}
