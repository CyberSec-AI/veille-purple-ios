import SwiftUI

struct SwipeView: View {
    @StateObject private var viewModel = SwipeViewModel()
    @State private var triggerAction: SwipeAction?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.04, blue: 0.12),
                    Color(red: 0.12, green: 0.06, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                cardStack
                actionButtons
            }
        }
        .task {
            await viewModel.loadArticles()
        }
        .refreshable {
            await viewModel.loadArticles()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, Color(red: 0.65, green: 0.45, blue: 0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("TindSec")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            Spacer()
            statsView
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private var statsView: some View {
        HStack(spacing: 14) {
            StatPill(icon: "xmark", value: viewModel.swipeStats.passes, color: .red)
            StatPill(icon: "heart.fill", value: viewModel.swipeStats.likes, color: .green)
            StatPill(icon: "star.fill", value: viewModel.swipeStats.superLikes, color: .blue)
        }
        .contextMenu {
            Button(role: .destructive) {
                viewModel.resetStats()
            } label: {
                Label("Réinitialiser les compteurs", systemImage: "arrow.counterclockwise")
            }
        }
    }

    // MARK: - Card stack
    private var cardStack: some View {
        ZStack {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadArticles() }
                }
            } else if viewModel.articles.isEmpty {
                EmptyStateView {
                    Task { await viewModel.loadArticles() }
                }
            } else {
                ForEach(Array(viewModel.articles.prefix(3).enumerated()), id: \.element.id) { index, article in
                    let isTop = index == 0
                    CardView(
                        article: article,
                        onSwipe: { action in
                            viewModel.handleSwipe(article: article, action: action)
                        },
                        triggerAction: isTop ? $triggerAction : .constant(nil)
                    )
                    .zIndex(Double(viewModel.articles.count - index))
                    .scaleEffect(1.0 - CGFloat(index) * 0.04)
                    .offset(y: CGFloat(index) * 8)
                    .allowsHitTesting(isTop)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }

    // MARK: - Buttons
    private var actionButtons: some View {
        HStack(spacing: 24) {
            ActionButton(action: .pass, size: 56) {
                triggerAction = .pass
            }
            ActionButton(action: .superLike, size: 64) {
                triggerAction = .superLike
            }
            ActionButton(action: .like, size: 56) {
                triggerAction = .like
            }
        }
        .padding(.vertical, 20)
        .opacity(viewModel.articles.isEmpty ? 0.3 : 1.0)
        .disabled(viewModel.articles.isEmpty)
    }
}

// MARK: - Stat pill
struct StatPill: View {
    let icon: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text("\(value)")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(10)
    }
}
