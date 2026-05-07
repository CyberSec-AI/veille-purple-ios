import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var url: String = ""
    @State private var apiKey: String = ""
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Backend n8n") {
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Clé API (optionnel)", text: $apiKey)

                    Button("Sauvegarder") {
                        var clean = url.trimmingCharacters(in: .whitespaces)
                        if clean.hasSuffix("/") { clean.removeLast() }
                        config.apiBaseURL = clean
                        config.apiKey = apiKey
                    }
                    .disabled(url.isEmpty)
                }

                Section("Endpoints attendus") {
                    Text("GET  /webhook/articles/pending")
                    Text("GET  /webhook/articles/matches")
                    Text("POST /webhook/feedback")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)

                Section("Geste de swipe") {
                    Label("Glisser à droite : LIKE", systemImage: "heart.fill")
                        .foregroundColor(.green)
                    Label("Glisser à gauche : PASS", systemImage: "xmark")
                        .foregroundColor(.red)
                    Label("Glisser vers le haut : SUPER LIKE", systemImage: "star.fill")
                        .foregroundColor(.blue)
                    Label("Double tap : voir le détail", systemImage: "hand.tap.fill")
                        .foregroundColor(.gray)
                }

                Section {
                    Button("Réinitialiser la configuration", role: .destructive) {
                        showResetAlert = true
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.gray)
                    }
                    HStack {
                        Text("Veille Purple Team")
                        Spacer()
                        Text("MCAR4 2025/2026").foregroundColor(.gray)
                    }
                }
                .font(.caption)
            }
            .navigationTitle("Paramètres")
            .onAppear {
                url = config.apiBaseURL
                apiKey = config.apiKey
            }
            .alert("Réinitialiser ?", isPresented: $showResetAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Réinitialiser", role: .destructive) {
                    config.reset()
                }
            } message: {
                Text("L'URL et la clé API seront supprimées.")
            }
        }
    }
}
