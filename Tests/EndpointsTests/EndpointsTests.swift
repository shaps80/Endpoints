import XCTest
@testable import Endpoints

final class EndpointsTests: XCTestCase {
    func testDataSuccess() async throws {
        let service = EndpointService(
            domain: .mockDomain
        )

        let (data, response) = try await service.perform(.mockData)
        XCTAssert(!data.isEmpty)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testJSONSuccess() async throws {
        let service = EndpointService(
            domain: .mockDomain
        )

        let (_, response) = try await service.perform(.mockJSON(filename: "gist"))
        XCTAssertEqual(response.statusCode, 200)
    }

    func testBadStatusCode() async {
        let service = EndpointService(
            domain: .mockDomain(code: 404)
        )

        do {
            _ = try await service.perform(.mockJSON(filename: "gist"))
            XCTFail("Expected error, got success")
        } catch let EndpointError.badResponse(response) {
            XCTAssertEqual(response.statusCode, 404)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testCorruptJSON() async throws {
        let service = EndpointService(
            domain: .mockDomain
        )

        do {
            _ = try await service.perform(.mockJSON(filename: "corrupt"))
            XCTFail("Expected error, got success")
        } catch EndpointError.decoding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testMisTypeJSON() async throws {
        let service = EndpointService(
            domain: .mockDomain
        )

        do {
            _ = try await service.perform(.mockJSON(filename: "mistype"))
            XCTFail("Expected error, got success")
        } catch EndpointError.decoding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testPostJSON() async throws {
        let service = EndpointService(
            domain: .mockDomain
        )

        let (_, response) = try await service.perform(.mockEncodable)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testPostJSONGetJSON() async throws {
        let service = EndpointService(
            domain: .mockDomain
        )

        let (result, response) = try await service.perform(.mockCodable)
        XCTAssertTrue(result.success)
        XCTAssertEqual(response.statusCode, 200)
    }
}

private struct MockGist: Identifiable, Codable {
    var id: String
    var description: String
    var updated: Date
}

private struct MockSuccess: Decodable {
    var success: Bool
}

private struct MockEncodableEndpoint: EncodableEndpoint {
    var body: some Encodable {
        MockGist(id: "0", description: "description", updated: Date())
    }

    var request: Request {
        Request(.get, path: "")
    }
}

private extension EncodableEndpoint where Self == MockEncodableEndpoint {
    static var mockEncodable: Self { .init() }
}

private struct MockCodableEndpoint: CodableEndpoint {
    typealias Output = MockSuccess
    var body: some Encodable {
        MockGist(id: "-1", description: "description", updated: Date())
    }
    var request: Request {
        Request(.post, path: "success")
    }
}

private extension EncodableEndpoint where Self == MockCodableEndpoint {
    static var mockCodable: Self { .init() }
}

private struct MockDataEndpoint: DecodableEndpoint {
    typealias Output = Data
    var request: Request {
        .init(.get, path: "")
    }
}

private struct MockJSONEndpoint: DecodableEndpoint {
    typealias Output = MockGist
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    var request: Request
}

extension Endpoint where Self == MockDataEndpoint {
    static var mockData: Self { .init() }
}

extension Endpoint where Self == MockJSONEndpoint {
    static func mockJSON(filename: String) -> Self {
        .init(request: .init(.get, path: filename))
    }
}

private struct MockDomain: Domain {
    var statusCode: Int
    let urlSession = URLSession(configuration: .ephemeral)

    func baseUrl<E>(for endpoint: E) async throws -> URL where E : Endpoint {
        guard let url = Bundle.module.url(forResource: endpoint.request.path, withExtension: "json") else {
            throw EndpointError.badEndpoint("Mock file missing from bundle: \(endpoint.request)")
        }
        return url
    }

    func urlRequest<E>(for endpoint: E) async throws -> URLRequest where E: Endpoint {
        try await URLRequest(url: baseUrl(for: endpoint))
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let data = try Data(contentsOf: request.url!)
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}

extension Domain where Self == MockDomain {
    static var mockDomain: Self { .init(statusCode: 200) }
    static func mockDomain(code: Int) -> Self {
        .init(statusCode: code)
    }
}
