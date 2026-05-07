# Veille Purple — App iOS Tinder-like

App iOS pour swiper la veille cybersécurité Purple Team générée par n8n + Gemini.

- **Swipe droite** = LIKE (article intéressant)
- **Swipe gauche** = PASS (rejeté, alimente le filtre IA)
- **Swipe haut** = SUPER LIKE (sauvegardé dans Matches)
- **Double tap** = ouvrir le détail

Les retours sont stockés dans PostgreSQL pour, à terme, fine-tuner le prompt Gemini sur tes préférences réelles.

## Stack

- **Frontend** : SwiftUI iOS 16+
- **Backend** : n8n (webhooks) + PostgreSQL
- **Build** : XcodeGen + GitHub Actions → `.ipa` non signé pour SideStore

## Installation rapide

### 1. Créer le repo GitHub

```bash
cd VeillePurple
git init
git add .
git commit -m "Initial: Veille Purple iOS app"
gh repo create veille-purple-ios --public --source=. --push
```

### 2. Compilation automatique

Le workflow `.github/workflows/build.yml` se déclenche à chaque push sur `main`.

Va dans l'onglet **Actions** de ton repo → attends que le job vert se termine → télécharge l'artifact `VeillePurple-unsigned-ipa`.

Une **release GitHub** est aussi créée automatiquement avec le `.ipa` attaché.

### 3. Setup backend

Dans `backend/` :

1. Exécute `schema.sql` sur ton PostgreSQL (via Coolify ou psql)
2. Suis `n8n-webhooks-guide.md` pour créer les 3 webhooks
3. Modifie ton workflow Gemini existant pour stocker les articles en base

### 4. Installer le `.ipa` via SideStore

1. Télécharge le `.ipa` depuis la release GitHub
2. Ouvre-le avec SideStore sur iOS
3. Au premier lancement, entre l'URL de ton n8n : `http://10.8.0.201:5678`

## Structure du projet

```
VeillePurple/
├── project.yml                     # XcodeGen spec
├── VeillePurple/
│   ├── VeillePurpleApp.swift       # Entry point
│   ├── ContentView.swift           # TabView racine + first-run
│   ├── Info.plist
│   ├── Models/
│   │   ├── Article.swift
│   │   └── SwipeAction.swift
│   ├── Services/
│   │   ├── APIService.swift        # Client HTTP n8n
│   │   └── ConfigManager.swift     # @AppStorage pour URL/clé
│   ├── ViewModels/
│   │   ├── SwipeViewModel.swift
│   │   └── MatchesViewModel.swift
│   ├── Views/
│   │   ├── SwipeView.swift         # Tab principal
│   │   ├── CardView.swift          # Carte animée
│   │   ├── MatchesView.swift       # Liste des super likes
│   │   ├── DetailView.swift        # Détail article
│   │   ├── SettingsView.swift
│   │   └── Components/             # ActionButton, badges, overlays...
│   └── Assets.xcassets/
├── backend/
│   ├── schema.sql                  # Tables PostgreSQL
│   └── n8n-webhooks-guide.md
└── .github/workflows/build.yml
```

## Compiler localement (optionnel)

Si tu as Xcode sur Mac :

```bash
brew install xcodegen
xcodegen generate
open VeillePurple.xcodeproj
```

## Roadmap

- [x] V1 : Swipe Tinder-like + intégration n8n + Matches
- [ ] V2 : Notifications push à chaque nouveau lot d'articles
- [ ] V3 : Partage Telegram depuis l'app
- [ ] V4 : Fine-tuning du prompt Gemini avec `feedback_stats`
- [ ] V5 : Mode hors-ligne avec sync différée

## Licence

Projet académique MCAR4 Cybersécurité 2025/2026 — Tommi Geron.
