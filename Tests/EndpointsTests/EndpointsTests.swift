import XCTest
@testable import Endpoints

final class EndpointsTests: XCTestCase {
    func testDataSuccess() async throws {
        let service = EndpointService(
            session: MockSession(statusCode: 200)
        )

        let (data, response) = try await service.perform(.mockData, from: .mockDomain)
        XCTAssert(!data.isEmpty)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testJSONSuccess() async throws {
        let service = EndpointService(
            session: MockSession(statusCode: 200)
        )

        let (_, response) = try await service.perform(.mockJSON(filename: "gist"), from: .mockDomain)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testBadStatusCode() async {
        let service = EndpointService(
            session: MockSession(statusCode: 404)
        )

        do {
            _ = try await service.perform(.mockJSON(filename: "gist"), from: .mockDomain)
            XCTFail("Expected error, got success")
        } catch let EndpointError.badResponse(response) {
            XCTAssertEqual(response.statusCode, 404)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testCorruptJSON() async throws {
        let service = EndpointService(
            session: MockSession(statusCode: 200)
        )

        do {
            _ = try await service.perform(.mockJSON(filename: "corrupt"), from: .mockDomain)
            XCTFail("Expected error, got success")
        } catch EndpointError.decoding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testMisTypeJSON() async throws {
        let service = EndpointService(
            session: MockSession(statusCode: 200)
        )

        do {
            _ = try await service.perform(.mockJSON(filename: "mistype"), from: .mockDomain)
            XCTFail("Expected error, got success")
        } catch EndpointError.decoding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testPostJSON() async throws {
        let service = EndpointService(
            session: MockSession(statusCode: 200)
        )

        let (_, response) = try await service.perform(.mockEncodable, from: .mockDomain)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testPostJSONGetJSON() async throws {
        let service = EndpointService(
            session: MockSession(statusCode: 200)
        )

        let (result, response) = try await service.perform(.mockCodable, from: .mockDomain)
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

    var path: Path {
        .init(path: "")
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
    var path: Path {
        .init(path: "success")
    }
}

private extension EncodableEndpoint where Self == MockCodableEndpoint {
    static var mockCodable: Self { .init() }
}

private struct MockDataEndpoint: DecodableEndpoint {
    typealias Output = Data
    var path: Path {
        .init(path: "")
    }
}

private struct MockJSONEndpoint: DecodableEndpoint {
    typealias Output = MockGist
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    var path: Path
}

extension Endpoint where Self == MockDataEndpoint {
    static var mockData: Self { .init() }
}

extension Endpoint where Self == MockJSONEndpoint {
    static func mockJSON(filename: String) -> Self {
        .init(path: .init(path: filename))
    }
}

private struct MockDomain: Domain {
    func request<E>(for endpoint: E) async throws -> URLRequest where E : Endpoint {
        guard let url = Bundle.module.url(forResource: endpoint.path.path, withExtension: "json") else {
            throw EndpointError.badEndpoint("Mock file missing from bundle: \(endpoint.path)")
        }

        return URLRequest(url: url)
    }
}

extension Domain where Self == MockDomain {
    static var mockDomain: Self { .init() }
}

private struct MockSession: EndpointSession {
    var urlSession: URLSession = .init(configuration: .ephemeral)
    var statusCode: Int = 200

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
