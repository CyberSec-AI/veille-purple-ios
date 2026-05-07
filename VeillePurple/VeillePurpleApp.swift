import SwiftUI

@main
struct VeillePurpleApp: App {
    @StateObject private var config = ConfigManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(config)
                .preferredColorScheme(.dark)
        }
    }
}
