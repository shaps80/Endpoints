import Foundation

public struct LimitQueryKey: QueryKey {
    public typealias Value = Int
    public static let name: String = "limit"
}

public extension Query {
    var limit: Int? {
        get { self[LimitQueryKey.self] }
        set { self[LimitQueryKey.self] = newValue }
    }
}
