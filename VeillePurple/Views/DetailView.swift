import SwiftUI

struct DetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var showSourceInfo: Bool = false

    private var matchedSource: Source? {
        SourcesRegistry.source(forArticleURL: article.url)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Volet header
                    HStack {
                        VoletBadge(volet: article.volet, color: article.voletColor)
                        PertinenceBadge(level: article.pertinence)
                        Spacer()
                    }

                    // Title
                    Text(article.titreFr)
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    // Source row — opens SourceInfoView when tapped
                    Button {
                        if matchedSource != nil { showSourceInfo = true }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: matchedSource != nil ? "person.crop.circle.fill" : "globe")
                                .foregroundColor(matchedSource?.voletColor ?? .gray)
                            Text(matchedSource?.name ?? URL(string: article.url)?.host ?? "")
                                .font(.subheadline.weight(matchedSource != nil ? .semibold : .regular))
                                .foregroundColor(matchedSource != nil ? .white : .gray)
                            if matchedSource != nil {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            if let lang = article.langueSource {
                                Text("·")
                                    .foregroundColor(.gray)
                                Text(lang.uppercased())
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(matchedSource == nil)

                    Divider()

                    // Summary
                    Text(article.resumeFr)
                        .font(.body)
                        .lineSpacing(6)

                    // Tags
                    if !article.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)
                            FlowLayout(spacing: 6) {
                                ForEach(article.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(article.voletColor.opacity(0.2))
                                        .foregroundColor(article.voletColor)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // About-the-source mini card
                    if let source = matchedSource {
                        Button {
                            showSourceInfo = true
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(source.voletColor)
                                    .frame(width: 4)
                                    .frame(maxHeight: .infinity)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("À propos de \(source.name)")
                                        .font(.subheadline.weight(.semibold))
                                    Text(source.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(source.voletColor.opacity(0.3), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // Open link
                    if let url = URL(string: article.url) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "safari.fill")
                                Text("Ouvrir l'article")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [.pink, Color(red: 0.65, green: 0.45, blue: 0.95)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                        }
                        .padding(.top, 12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .sheet(isPresented: $showSourceInfo) {
                if let source = matchedSource {
                    SourceInfoView(source: source)
                }
            }
        }
    }
}

// FlowLayout — kept as-is (used by both DetailView and SourceInfoView)
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width + spacing
                rowHeight = size.height
            } else {
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
