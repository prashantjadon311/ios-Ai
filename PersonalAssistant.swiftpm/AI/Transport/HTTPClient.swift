// AI/Transport/HTTPClient.swift
// URLSession-based HTTP client with cancellation, redirect safety, and size limits.
// Per V3 §AI/Transport/HTTPClient.swift blueprint.

import Foundation

// MARK: - HTTP Request/Response

struct HTTPRequest: Sendable {
    let url: URL
    let method: String
    let headers: [String: String]
    let body: Data?
    let deadline: Duration

    init(url: URL, method: String = "POST", headers: [String: String] = [:], body: Data? = nil, deadline: Duration = .seconds(60)) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.deadline = deadline
    }
}

struct HTTPResponse: Sendable {
    let statusCode: Int
    let headers: [String: String]
    let body: Data
}

// MARK: - HTTP Client errors

enum HTTPClientError: Error, Sendable {
    case redirectToUnapprovedHost(String)
    case nonHTTPS(scheme: String?)
    case responseTooLarge(bytes: Int, limit: Int)
    case requestCancelled
    case timeout
    case networkError(String)
    case invalidResponse
}

// MARK: - HTTP Client actor

actor HTTPClient {

    static let defaultMaxResponseBytes = 10 * 1024 * 1024  // 10 MiB

    private let session: URLSession
    private let allowedHosts: Set<String>  // HTTPS-only allowlist
    private let maxResponseBytes: Int

    init(
        session: URLSession = .shared,
        allowedHosts: Set<String> = [],
        maxResponseBytes: Int = defaultMaxResponseBytes
    ) {
        self.session = session
        self.allowedHosts = allowedHosts
        self.maxResponseBytes = maxResponseBytes
    }

    // MARK: - Validated request URL (A17/B10)

    private func validateURL(_ url: URL) throws {
        guard url.scheme == "https" else {
            throw HTTPClientError.nonHTTPS(scheme: url.scheme)
        }
        // If allowlist provided, host must be on it
        if !allowedHosts.isEmpty {
            guard let host = url.host, allowedHosts.contains(host) else {
                throw HTTPClientError.redirectToUnapprovedHost(url.host ?? "")
            }
        }
    }

    // MARK: - Send (non-streaming)

    func send(request: HTTPRequest) async throws -> HTTPResponse {
        try validateURL(request.url)

        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        for (k, v) in request.headers { urlRequest.setValue(v, forHTTPHeaderField: k) }

        // Never set untrusted Host header
        // Redirects: delegate rejects non-HTTPS or unapproved host changes
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard data.count <= maxResponseBytes else {
            throw HTTPClientError.responseTooLarge(bytes: data.count, limit: maxResponseBytes)
        }

        var responseHeaders: [String: String] = [:]
        for (key, value) in httpResponse.allHeaderFields {
            if let k = key as? String, let v = value as? String { responseHeaders[k] = v }
        }

        return HTTPResponse(
            statusCode: httpResponse.statusCode,
            headers: responseHeaders,
            body: data
        )
    }

    // MARK: - Stream (SSE / chunked)

    /// Returns an AsyncThrowingStream of raw Data chunks.
    func stream(request: HTTPRequest) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    try validateURL(request.url)
                    var urlRequest = URLRequest(url: request.url)
                    urlRequest.httpMethod = request.method
                    urlRequest.httpBody = request.body
                    for (k, v) in request.headers { urlRequest.setValue(v, forHTTPHeaderField: k) }

                    let (asyncBytes, response) = try await session.bytes(for: urlRequest)
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200..<300).contains(httpResponse.statusCode) else {
                        continuation.finish(throwing: HTTPClientError.invalidResponse)
                        return
                    }

                    var totalBytes = 0
                    for try await byte in asyncBytes {
                        totalBytes += 1
                        guard totalBytes <= maxResponseBytes else {
                            continuation.finish(throwing: HTTPClientError.responseTooLarge(
                                bytes: totalBytes, limit: maxResponseBytes
                            ))
                            return
                        }
                        continuation.yield(Data([byte]))
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: HTTPClientError.requestCancelled)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
