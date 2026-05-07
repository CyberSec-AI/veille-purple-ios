import SwiftUI

struct SwipeOverlay: View {
    let action: SwipeAction
    let opacity: Double
    let alignment: Alignment

    var body: some View {
        VStack {
            HStack {
                if alignment == .topTrailing { Spacer() }

                Text(action.label)
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(action.color)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(action.color, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(rotationAngle))

                if alignment == .topLeading { Spacer() }
            }
            Spacer()
        }
        .padding(28)
        .opacity(opacity)
        .allowsHitTesting(false)
    }

    private var rotationAngle: Double {
        switch action {
        case .pass: return 18
        case .like: return -18
        case .superLike: return 0
        }
    }
}
