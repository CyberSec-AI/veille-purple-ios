import Foundation
import SwiftUI

@MainActor
class SwipeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var swipeStats: SwipeStats = .init()
    @Published var triggerSwipe: SwipeAction?

    struct SwipeStats {
        var passes: Int = 0
        var likes: Int = 0
        var superLikes: Int = 0
        var total: Int { passes + likes + superLikes }
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

        // Update stats
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
