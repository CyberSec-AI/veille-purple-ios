import SwiftUI

struct CardView: View {
    let article: Article
    let onSwipe: (SwipeAction) -> Void
    @Binding var triggerAction: SwipeAction?

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var isGone: Bool = false
    @State private var showDetail: Bool = false
    @State private var showSourceInfo: Bool = false   // ← NEW

    private let swipeThreshold: CGFloat = 120

    /// Source matched from the article URL (nil if no match in registry)
    private var matchedSource: Source? {
        SourcesRegistry.source(forArticleURL: article.url)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                article.voletColor.opacity(0.85),
                                article.voletColor.opacity(0.4),
                                Color.black.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 14) {
                    // Top row — volet + pertinence + (i) source info
                    HStack {
                        VoletBadge(volet: article.volet, color: article.voletColor)
                        Spacer()
                        PertinenceBadge(level: article.pertinence)

                        // ← NEW : source info button
                        if matchedSource != nil {
                            Button {
                                showSourceInfo = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.9))
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 30, height: 30)
                                    )
                            }
                            .buttonStyle(.plain)
                            // Stop drag gesture from hijacking the tap
                            .highPriorityGesture(
                                TapGesture().onEnded { showSourceInfo = true }
                            )
                        }
                    }

                    Spacer().frame(height: 4)

                    Text(article.titreFr)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)

                    ScrollView(showsIndicators: false) {
                        Text(article.resumeFr)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.92))
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !article.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(article.tags.prefix(8), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 12, weight: .medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.15))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    // Source row — clickable when matched
                    Button {
                        if matchedSource != nil { showSourceInfo = true }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: matchedSource != nil ? "person.crop.circle.fill" : "link")
                                .font(.caption2)
                            Text(matchedSource?.name ?? URL(string: article.url)?.host ?? article.url)
                                .font(.caption)
                                .lineLimit(1)
                            if matchedSource != nil {
                                Image(systemName: "info.circle")
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .disabled(matchedSource == nil)
                }
                .padding(24)

                SwipeOverlay(action: .pass, opacity: passOpacity, alignment: .topTrailing)
                SwipeOverlay(action: .like, opacity: likeOpacity, alignment: .topLeading)
                SwipeOverlay(action: .superLike, opacity: superLikeOpacity, alignment: .top)
            }
            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
        }
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .opacity(isGone ? 0 : 1)
        .gesture(dragGesture)
        .onTapGesture(count: 2) {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            DetailView(article: article)
        }
        .sheet(isPresented: $showSourceInfo) {
            if let source = matchedSource {
                SourceInfoView(source: source)
            }
        }
        .onChange(of: triggerAction) { newAction in
            if let action = newAction {
                performProgrammaticSwipe(action)
                triggerAction = nil
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                offset = gesture.translation
                rotation = Double(gesture.translation.width / 20)
            }
            .onEnded { gesture in
                let h = gesture.translation.width
                let v = gesture.translation.height

                if v < -swipeThreshold && abs(h) < abs(v) {
                    flyOff(action: .superLike)
                } else if h > swipeThreshold {
                    flyOff(action: .like)
                } else if h < -swipeThreshold {
                    flyOff(action: .pass)
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        offset = .zero
                        rotation = 0
                    }
                }
            }
    }

    private func performProgrammaticSwipe(_ action: SwipeAction) {
        flyOff(action: action)
    }

    private func flyOff(action: SwipeAction) {
        let target: CGSize
        let rot: Double
        switch action {
        case .pass:
            target = CGSize(width: -800, height: offset.height)
            rot = -25
        case .like:
            target = CGSize(width: 800, height: offset.height)
            rot = 25
        case .superLike:
            target = CGSize(width: offset.width, height: -1000)
            rot = 0
        }
        withAnimation(.easeOut(duration: 0.35)) {
            offset = target
            rotation = rot
            isGone = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            onSwipe(action)
        }
    }

    private var likeOpacity: Double {
        offset.width > 0 && abs(offset.width) > abs(offset.height)
            ? min(Double(offset.width) / Double(swipeThreshold), 1.0)
            : 0
    }

    private var passOpacity: Double {
        offset.width < 0 && abs(offset.width) > abs(offset.height)
            ? min(Double(-offset.width) / Double(swipeThreshold), 1.0)
            : 0
    }

    private var superLikeOpacity: Double {
        offset.height < 0 && abs(offset.height) > abs(offset.width)
            ? min(Double(-offset.height) / Double(swipeThreshold), 1.0)
            : 0
    }
}
