import Foundation
import SwiftUI

struct Article: Codable, Identifiable, Equatable {
    let id: Int
    let articleId: String
    let titreFr: String
    let url: String
    let resumeFr: String
    let volet: String
    let pertinence: String
    let tags: [String]
    let langueSource: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case articleId = "article_id"
        case titreFr = "titre_fr"
        case url
        case resumeFr = "resume_fr"
        case volet
        case pertinence
        case tags
        case langueSource = "langue_source"
        case createdAt = "created_at"
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

extension Article {
    var voletColor: Color {
        switch volet.lowercased() {
        case "offensif":
            return Color(red: 0.91, green: 0.32, blue: 0.27)
        case "re":
            return Color(red: 0.30, green: 0.65, blue: 0.95)
        case "purple":
            return Color(red: 0.65, green: 0.45, blue: 0.95)
        default:
            return .gray
        }
    }

    var voletEmoji: String {
        switch volet.lowercased() {
        case "offensif": return "⚔️"
        case "re": return "🔬"
        case "purple": return "🟣"
        default: return "📄"
        }
    }

    var pertinenceColor: Color {
        pertinence.lowercased() == "haute" ? .green : .orange
    }
}

// MARK: - Decoding helper for flexible API responses
struct ArticlesResponse: Codable {
    let articles: [Article]
}
