import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL n8n invalide"
        case .noData: return "Aucune donnée reçue"
        case .decodingError(let e): return "Erreur de décodage : \(e.localizedDescription)"
        case .httpError(let code): return "Erreur HTTP \(code)"
        case .networkError(let e): return "Erreur réseau : \(e.localizedDescription)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private init() {}

    private var config: ConfigManager { ConfigManager.shared }

    private func request(path: String, method: String = "GET", body: Data? = nil) -> URLRequest? {
        guard !config.apiBaseURL.isEmpty,
              let url = URL(string: "\(config.apiBaseURL)\(path)") else {
            return nil
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !config.apiKey.isEmpty {
            req.setValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
        }
        if let body = body {
            req.httpBody = body
        }
        return req
    }

    // MARK: - Fetch pending articles
    func fetchPendingArticles() async throws -> [Article] {
        guard let req = request(path: "/webhook/articles/pending") else {
            throw APIError.invalidURL
        }
        return try await fetchArticles(req: req)
    }

    // MARK: - Fetch matches (super-liked)
    func fetchMatches() async throws -> [Article] {
        guard let req = request(path: "/webhook/articles/matches") else {
            throw APIError.invalidURL
        }
        return try await fetchArticles(req: req)
    }

    // MARK: - Send feedback
    func sendFeedback(articleId: String, action: SwipeAction) async throws {
        let payload: [String: String] = [
            "article_id": articleId,
            "action": action.rawValue
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        guard let req = request(path: "/webhook/feedback", method: "POST", body: body) else {
            throw APIError.invalidURL
        }
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
    }

    // MARK: - Helper
    private func fetchArticles(req: URLRequest) async throws -> [Article] {
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw APIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            // Handle two possible response formats:
            // 1) Array of articles
            // 2) { "articles": [...] }
            let decoder = JSONDecoder()
            if let array = try? decoder.decode([Article].self, from: data) {
                return array
            }
            if let wrapped = try? decoder.decode(ArticlesResponse.self, from: data) {
                return wrapped.articles
            }
            throw APIError.decodingError(NSError(domain: "VeillePurple", code: -1, userInfo: [NSLocalizedDescriptionKey: "Format de réponse inconnu"]))
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
