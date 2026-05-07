import SwiftUI

struct ActionButton: View {
    let action: SwipeAction
    var size: CGFloat = 56
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
            onTap()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: size, height: size)
                    .shadow(color: action.color.opacity(0.6), radius: 12, x: 0, y: 4)

                Image(systemName: action.icon)
                    .font(.system(size: size * 0.42, weight: .heavy))
                    .foregroundColor(action.color)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
