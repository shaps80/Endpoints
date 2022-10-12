import Foundation
import SwiftUI

public protocol QueryKey {
    associatedtype Value: CustomStringConvertible = String
    static var name: String { get }
}

public struct Query {
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

    public init<V>(_ keyPath: WritableKeyPath<Query, V>, _ value: V) {
        self[keyPath: keyPath] = value
    }

    public subscript<K>(key: K.Type) -> K.Value? where K: QueryKey {
        get { nil }
        set {
            self.name = K.name
            self.value = newValue
        }
    }
}

extension Query: CustomStringConvertible {
    public var description: String {
        let v = "\(value ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "\(name)=\(v)"
    }
}

extension Query: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(name): \(value ?? "<none>")"
    }
}

extension Query {
    var queryItem: URLQueryItem? {
        value.flatMap { .init(name: name, value: "\($0)") }
    }
}

public protocol Queries {
    var queries: [Query] { get }
}

extension Query: Queries {
    public var queries: [Query] { [self] }
}

extension Array: Queries where Element == Query {
    public var queries: [Element] { self }
}

public struct EmptyQuery: Queries {
    public var queries: [Query] { [] }
    public init() { }
}

@resultBuilder
public struct QueryBuilder {
    public static func buildBlock(_ components: Queries...) -> [Query] {
        components.flatMap { $0.queries }
    }

    public static func buildOptional(_ component: Queries?) -> [Query] {
        component.map { $0.queries } ?? []
    }

    public static func buildEither(first component: Queries) -> [Query] {
        component.queries
    }

    public static func buildEither(second component: Queries) -> [Query] {
        component.queries
    }

    public static func buildArray(_ components: [Queries]) -> [Query] {
        components.flatMap { $0.queries }
    }

    public static func buildLimitedAvailability(_ component: Queries) -> [Query] {
        component.queries
    }
}
