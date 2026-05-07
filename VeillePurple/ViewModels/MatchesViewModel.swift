import Foundation

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            articles = try await APIService.shared.fetchMatches()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            articles = []
        }
        isLoading = false
    }
}
