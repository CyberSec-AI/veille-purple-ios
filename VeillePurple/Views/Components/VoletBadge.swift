import SwiftUI

struct VoletBadge: View {
    let volet: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(volet.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct PertinenceBadge: View {
    let level: String

    var color: Color {
        level.lowercased() == "haute" ? .green : .orange
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.lowercased() == "haute" ? "flame.fill" : "circle.fill")
                .font(.system(size: 10))
            Text(level.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.0)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .cornerRadius(20)
    }
}
