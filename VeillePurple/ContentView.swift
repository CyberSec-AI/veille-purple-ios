import SwiftUI

struct ContentView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var selectedTab = 0

    var body: some View {
        if config.apiBaseURL.isEmpty {
            FirstRunView()
        } else {
            TabView(selection: $selectedTab) {
                SwipeView()
                    .tabItem {
                        Label("Stack", systemImage: "rectangle.stack.fill")
                    }
                    .tag(0)

                MatchesView()
                    .tabItem {
                        Label("Matches", systemImage: "star.fill")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(Color(red: 0.65, green: 0.45, blue: 0.95))
        }
    }
}

struct FirstRunView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var url = ""
    @State private var apiKey = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.05, blue: 0.20),
                    Color(red: 0.20, green: 0.05, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, Color(red: 0.65, green: 0.45, blue: 0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Veille Purple")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))

                Text("Configure ton serveur n8n")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                VStack(spacing: 16) {
                    TextField("URL n8n (ex: http://10.8.0.201:5678)", text: $url)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Clé API (optionnel)", text: $apiKey)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)

                Button(action: {
                    var cleanURL = url.trimmingCharacters(in: .whitespaces)
                    if cleanURL.hasSuffix("/") {
                        cleanURL.removeLast()
                    }
                    config.apiBaseURL = cleanURL
                    config.apiKey = apiKey
                }) {
                    Text("Commencer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.pink, Color(red: 0.65, green: 0.45, blue: 0.95)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal, 32)
                .disabled(url.isEmpty)
                .opacity(url.isEmpty ? 0.5 : 1.0)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConfigManager.shared)
}
