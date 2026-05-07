import Foundation
import SwiftUI

enum SwipeAction: String, Codable, CaseIterable {
    case pass = "pass"
    case like = "like"
    case superLike = "super_like"

    var icon: String {
        switch self {
        case .pass: return "xmark"
        case .like: return "heart.fill"
        case .superLike: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .pass: return Color(red: 1.0, green: 0.30, blue: 0.40)
        case .like: return Color(red: 0.20, green: 0.85, blue: 0.50)
        case .superLike: return Color(red: 0.30, green: 0.65, blue: 0.95)
        }
    }

    var label: String {
        switch self {
        case .pass: return "PASS"
        case .like: return "LIKE"
        case .superLike: return "SUPER"
        }
    }
}
