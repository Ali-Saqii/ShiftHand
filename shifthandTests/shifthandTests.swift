//
//  shifthandTests.swift
//  shifthandTests
//
//  Day 1 Unit Tests: Endpoint construction, API error decoding, and Keychain storage.
//

import Testing
import Foundation
@testable import shifthand

struct Day1Tests {

    // MARK: - Endpoint & URL Request Tests

    @Test func testEndpointURLConstruction() throws {
        let baseURL = URL(string: "http://localhost:3000/api/v1")!
        let endpoint = Endpoint(
            path: "/events",
            method: .get,
            queryItems: [URLQueryItem(name: "status", value: "upcoming")],
            headers: ["X-Test": "Value"],
            idempotencyKey: "idem_12345"
        )

        let request = try endpoint.urlRequest(baseURL: baseURL, token: "test_jwt_token")

        #expect(request.url?.absoluteString == "http://localhost:3000/api/v1/events?status=upcoming")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test_jwt_token")
        #expect(request.value(forHTTPHeaderField: "Idempotency-Key") == "idem_12345")
        #expect(request.value(forHTTPHeaderField: "X-Test") == "Value")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func testEndpointPathNormalization() throws {
        let baseURL = URL(string: "https://api.shifthand.org/api/v1/")!
        let endpoint = Endpoint(path: "events/4411/shifts")

        let request = try endpoint.urlRequest(baseURL: baseURL)
        #expect(request.url?.path == "/api/v1/events/4411/shifts")
    }

    // MARK: - API Error Mapping Tests

    @Test func testServerErrorEnvelopeDecoding() throws {
        let json = """
        {
            "error": {
                "code": "SHIFT_FULL",
                "message": "This shift is full",
                "details": { "waitlistAvailable": "true" },
                "requestId": "req_abc123"
            }
        }
        """.data(using: .utf8)!

        let envelope = try JSONDecoder().decode(ServerErrorEnvelope.self, from: json)
        #expect(envelope.error.code == "SHIFT_FULL")
        #expect(envelope.error.message == "This shift is full")
        #expect(envelope.error.requestId == "req_abc123")

        let code = ServerErrorCode(rawValue: envelope.error.code)
        #expect(code == .shiftFull)
    }

    @Test func testAlreadyCheckedInErrorDetection() {
        let error = AppError.alreadyCheckedIn(checkedInAt: "09:14", message: "Already checked in")
        #expect(error.isAlreadyCheckedIn)
        #expect(error.errorDescription == "Already here since 09:14")
    }

    // MARK: - KeychainStore Tests

    @Test func testKeychainStoreSaveAndRetrieve() throws {
        let store = KeychainStore(keyPrefix: "test_shifthand_")
        let token = "test_refresh_token_256bit_sample"

        try store.saveRefreshToken(token)
        let retrieved = store.getRefreshToken()
        #expect(retrieved == token)

        try store.deleteRefreshToken()
        let afterDelete = store.getRefreshToken()
        #expect(afterDelete == nil)
    }

    // MARK: - Design Tokens & Metrics Tests

    @Test func testDesignMetricsCompliance() {
        #expect(SHMetrics.cardCornerRadius == 16)
        #expect(SHMetrics.buttonCornerRadius == 12)
        #expect(SHMetrics.chipCornerRadius == 8)
        #expect(SHMetrics.minTouchTarget >= 44)
    }
}
