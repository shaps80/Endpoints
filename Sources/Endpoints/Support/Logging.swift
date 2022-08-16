#if canImport(Logging)
import Logging

internal extension Logger {
    static let request = Logger(label: "req")
    static let response = Logger(label: "res")
}

internal extension Logger {
    static let decoding = Logger(label: "decode")
    static let encoding = Logger(label: "encode")
}
#endif
