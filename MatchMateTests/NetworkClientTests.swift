//
//  NetworkClientTests.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import XCTest
@testable import MatchMate

final class NetworkClientTests: XCTestCase {
    private func makeClient() -> NetworkClient {
        
        let configuration = URLSessionConfiguration.ephemeral
        
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]
        
        let session = URLSession(configuration: configuration)
        
        return URLSessionNetworkClient(session: session)
    }
    func testRequestReturnsDataForSuccessfulResponse() async throws {
        
        let expectedData = Data("success".utf8)
        
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        MockURLProtocol.responseData = expectedData
        MockURLProtocol.error = nil
        
        let client = makeClient()
        
        let request = URLRequest(
            url: URL(string: "https://example.com")!
        )
        
        let data = try await client.request(request)
        
        XCTAssertEqual(data, expectedData)
    }
    
    func testRequestThrowsHTTPErrorForNonSuccessStatusCode() async {
        
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        MockURLProtocol.responseData = Data()
        MockURLProtocol.error = nil
        
        let client = makeClient()
        
        let request = URLRequest(
            url: URL(string: "https://example.com")!
        )
        
        do {
            _ = try await client.request(request)
            XCTFail("Expected NetworkError.httpError")
        } catch let error as NetworkError {
            
            switch error {
                case .httpError(let statusCode):
                    XCTAssertEqual(statusCode, 500)
                    
                default:
                    XCTFail("Unexpected NetworkError")
            }
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

final class MockURLProtocol: URLProtocol {
    
    static var response: URLResponse?
    static var responseData: Data?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = Self.response {
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }
        
        if let data = Self.responseData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
