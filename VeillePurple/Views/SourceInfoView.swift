import SwiftUI

struct SourceInfoView: View {
    let source: Source
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(source.voletColor)
                                .frame(width: 14, height: 14)
                            Text(source.volet.uppercased())
                                .font(.caption.bold())
                                .tracking(1.2)
                                .foregroundColor(source.voletColor)
                            Spacer()
                            Text(source.langueDrapeau)
                                .font(.title3)
                        }
                        Text(source.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }

                    // Note (if any)
                    if let note = source.note {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(10)
                    }

                    // Description
                    Text(source.description)
                        .font(.body)
                        .lineSpacing(5)

                    // Metadata grid
                    VStack(spacing: 0) {
                        MetadataRow(icon: "person.fill", label: "Auteurs", value: source.auteurs)
                        Divider().background(Color.white.opacity(0.1))
                        MetadataRow(icon: "calendar", label: "Fréquence", value: source.frequence)
                        Divider().background(Color.white.opacity(0.1))
                        MetadataRow(icon: "doc.text.fill", label: "Type", value: source.type.capitalized)
                        Divider().background(Color.white.opacity(0.1))
                        MetadataRow(icon: "globe", label: "Site", value: URL(string: source.url)?.host ?? source.url)
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )

                    // Tags
                    if !source.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)
                            FlowLayout(spacing: 6) {
                                ForEach(source.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(source.voletColor.opacity(0.2))
                                        .foregroundColor(source.voletColor)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Open buttons
                    VStack(spacing: 10) {
                        if let url = URL(string: source.url) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "safari.fill")
                                    Text("Ouvrir le site")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [source.voletColor, source.voletColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                            }
                        }

                        if let rssURL = URL(string: source.rss) {
                            Link(destination: rssURL) {
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                    Text("Flux RSS")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

private struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(14)
    }
}
