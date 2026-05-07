import Foundation
import SwiftUI

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    @AppStorage("apiBaseURL") var apiBaseURL: String = ""
    @AppStorage("apiKey") var apiKey: String = ""

    private init() {}

    func reset() {
        apiBaseURL = ""
        apiKey = ""
    }
}
