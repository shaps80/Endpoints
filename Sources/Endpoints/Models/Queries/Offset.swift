import Foundation

public struct OffsetQueryKey: QueryKey {
    public typealias Value = Int
    public static let name: String = "offset"
}

public extension Query {
    var offset: Int? {
        get { self[OffsetQueryKey.self] }
        set { self[OffsetQueryKey.self] = newValue }
    }
}
