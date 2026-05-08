import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()
    @State private var selectedArticle: Article?

    var body: some View {
        NavigationStack {
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

                Group {
                    if viewModel.isLoading && viewModel.articles.isEmpty {
                        ProgressView().scaleEffect(1.5).tint(.white)
                    } else if viewModel.articles.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "star.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Aucun super like")
                                .font(.title3.weight(.semibold))
                            Text("Swipe vers le haut pour ajouter")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.articles) { article in
                                    Button {
                                        selectedArticle = article
                                    } label: {
                                        MatchRow(article: article)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
            .sheet(item: $selectedArticle) { article in
                DetailView(article: article)
            }
        }
    }
}

struct MatchRow: View {
    let article: Article

    private var sourceName: String? {
        SourcesRegistry.source(forArticleURL: article.url)?.name
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(article.voletColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.voletEmoji)
                    Text(article.volet.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(article.voletColor)
                    if let source = sourceName {
                        Text("·")
                            .foregroundColor(.gray)
                        Text(source)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(article.pertinence.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(article.pertinenceColor)
                }
                Text(article.titreFr)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Text(article.resumeFr)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }
}
