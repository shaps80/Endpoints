import Foundation

public struct Request {
    var path: String
    var queries: [Query] = []
    var headers: [Header] = [
        Header(\.contentType, value: .json),
        Header(\.accept, value: .json)
    ]

    public init(path: String) {
        self.path = path
    }

    public init(path: String, @QueryBuilder queries: () -> [Query]) {
        self.path = path
        self.queries = queries()
    }

    public init(path: String, @HeadersBuilder headers: () -> [Header]) {
        self.path = path
        self.headers = headers()
    }

    public init(path: String, @QueryBuilder queries: () -> [Query], @HeadersBuilder headers: () -> [Header]) {
        self.path = path
        self.queries = queries()
        self.headers = headers()
    }
}
