import SwiftUI

struct SourcesDirectoryView: View {
    @State private var selectedFilter: VoletFilter = .all
    @State private var selectedSource: Source?
    @State private var searchText: String = ""

    enum VoletFilter: String, CaseIterable {
        case all = "Toutes"
        case offensif = "Offensif"
        case re = "RE"
        case purple = "Purple"
        case threatIntel = "Threat Intel"
        case misc = "Divers"

        var voletKey: String? {
            switch self {
            case .all: return nil
            case .offensif: return "offensif"
            case .re: return "RE"
            case .purple: return "purple"
            case .threatIntel: return "threat_intel"
            case .misc: return "misc"
            }
        }
    }

    private var filteredSources: [Source] {
        var sources = SourcesRegistry.all
        if let key = selectedFilter.voletKey {
            sources = sources.filter { $0.volet.lowercased() == key.lowercased() }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            sources = sources.filter {
                $0.name.lowercased().contains(q)
                || $0.description.lowercased().contains(q)
                || $0.tags.contains(where: { $0.lowercased().contains(q) })
            }
        }
        return sources.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

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

                VStack(spacing: 0) {
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(VoletFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    label: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)

                    // List
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredSources) { source in
                                Button {
                                    selectedSource = source
                                } label: {
                                    SourceListRow(source: source)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Sources")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Rechercher une source")
            .sheet(item: $selectedSource) { source in
                SourceInfoView(source: source)
            }
        }
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? AnyShapeStyle(LinearGradient(
                        colors: [.pink, Color(red: 0.65, green: 0.45, blue: 0.95)],
                        startPoint: .leading,
                        endPoint: .trailing
                      ))
                    : AnyShapeStyle(Color.white.opacity(0.08))
                )
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }
}

private struct SourceListRow: View {
    let source: Source

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(source.voletColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(source.name)
                        .font(.headline)
                    Spacer()
                    Text(source.langueDrapeau)
                        .font(.caption)
                }
                Text(source.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 6) {
                    Text(source.volet.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(source.voletColor.opacity(0.25))
                        .foregroundColor(source.voletColor)
                        .cornerRadius(4)
                    Text(source.frequence)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    if source.note != nil {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}
