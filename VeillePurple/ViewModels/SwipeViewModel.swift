import Foundation
import SwiftUI

@MainActor
class SwipeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var triggerSwipe: SwipeAction?

    // ✨ Stats persistées dans UserDefaults — survivent au redémarrage de l'app
    @Published var swipeStats: SwipeStats {
        didSet {
            saveStats()
        }
    }

    struct SwipeStats: Codable {
        var passes: Int = 0
        var likes: Int = 0
        var superLikes: Int = 0
        var total: Int { passes + likes + superLikes }

        // total est calculé, on ne l'encode pas
        enum CodingKeys: String, CodingKey {
            case passes, likes, superLikes
        }
    }

    private static let statsKey = "tindsec.swipeStats"

    init() {
        // Charge les stats depuis UserDefaults au démarrage
        if let data = UserDefaults.standard.data(forKey: Self.statsKey),
           let decoded = try? JSONDecoder().decode(SwipeStats.self, from: data) {
            self.swipeStats = decoded
        } else {
            self.swipeStats = SwipeStats()
        }
    }

    private func saveStats() {
        if let data = try? JSONEncoder().encode(swipeStats) {
            UserDefaults.standard.set(data, forKey: Self.statsKey)
        }
    }

    func resetStats() {
        swipeStats = SwipeStats()
    }

    func loadArticles() async {
        isLoading = true
        errorMessage = nil
        do {
            articles = try await APIService.shared.fetchPendingArticles()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            articles = []
        }
        isLoading = false
    }

    func handleSwipe(article: Article, action: SwipeAction) {
        // Optimistic UI: remove card immediately
        articles.removeAll { $0.id == article.id }

        // Update stats (déclenche didSet → sauvegarde UserDefaults)
        switch action {
        case .pass: swipeStats.passes += 1
        case .like: swipeStats.likes += 1
        case .superLike: swipeStats.superLikes += 1
        }

        // Haptic
        let feedback = UIImpactFeedbackGenerator(style: action == .superLike ? .heavy : .medium)
        feedback.impactOccurred()

        // Send to backend (fire and forget)
        Task {
            try? await APIService.shared.sendFeedback(
                articleId: article.articleId,
                action: action
            )
        }

        // Auto-refresh when stack runs low
        if articles.count < 3 {
            Task {
                if let fresh = try? await APIService.shared.fetchPendingArticles() {
                    let existingIds = Set(articles.map { $0.id })
                    let newOnes = fresh.filter { !existingIds.contains($0.id) }
                    articles.append(contentsOf: newOnes)
                }
            }
        }
    }

    func programmaticSwipe(_ action: SwipeAction) {
        triggerSwipe = action
    }
}
