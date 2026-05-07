# Backend Setup — n8n + PostgreSQL

L'app iOS communique avec ton serveur n8n via 3 webhooks. Voici la config complète.

## 1. Initialisation PostgreSQL

Dans Coolify, accède à ton PostgreSQL → onglet "Terminal" ou via DBeaver/psql :

```bash
psql -U <user> -d <db> -f schema.sql
```

Ou copie-colle le contenu de `schema.sql` directement.

## 2. Modifier le workflow existant — STORE après Gemini

Avant le nœud Telegram (ou en parallèle), ajoute un nœud **PostgreSQL** :

- **Operation** : Insert
- **Schema** : public
- **Table** : articles
- **Columns** :
  ```
  article_id   = {{ $crypto.MD5($json.url) }}
  titre_fr     = {{ $json.titre_fr }}
  url          = {{ $json.url }}
  resume_fr    = {{ $json.resume_fr }}
  volet        = {{ $json.volet }}
  pertinence   = {{ $json.pertinence }}
  tags         = {{ $json.tags }}
  langue_source = {{ $json.langue_source }}
  ```
- **On Conflict** : Do nothing (évite les doublons)

> Astuce : si le nœud n8n PostgreSQL ne supporte pas `crypto.MD5`, ajoute un nœud Code juste avant qui calcule le hash avec `require("crypto").createHash("md5").update(url).digest("hex")`.

## 3. Créer 3 nouveaux workflows n8n (webhooks)

### Workflow 1 : `GET /webhook/articles/pending`

Retourne les articles non-swipés, triés par date.

**Nœuds :**

1. **Webhook Trigger**
   - HTTP Method : GET
   - Path : `articles/pending`
   - Response Mode : "When Last Node Finishes"

2. **PostgreSQL** (Execute Query)
   ```sql
   SELECT id, article_id, titre_fr, url, resume_fr, volet, pertinence, tags, langue_source, created_at::text
   FROM articles
   WHERE swiped_at IS NULL
   ORDER BY
     CASE pertinence WHEN 'haute' THEN 1 ELSE 2 END,
     created_at DESC
   LIMIT 50;
   ```

3. **Respond to Webhook**
   - Response Body : `{{ $items().map(i => i.json) }}`
   - Content-Type : application/json

### Workflow 2 : `POST /webhook/feedback`

Enregistre un swipe et marque l'article comme swipé.

**Nœuds :**

1. **Webhook Trigger**
   - HTTP Method : POST
   - Path : `feedback`

2. **PostgreSQL** (Execute Query)
   ```sql
   INSERT INTO feedbacks (article_id, action)
   VALUES ('{{ $json.body.article_id }}', '{{ $json.body.action }}');

   UPDATE articles
   SET swiped_at = CURRENT_TIMESTAMP
   WHERE article_id = '{{ $json.body.article_id }}';
   ```

3. **Respond to Webhook**
   - Response Body : `{"status":"ok"}`

> ⚠️ Pour éviter l'injection SQL, configure le nœud PostgreSQL en mode **Parameters** avec des paramètres nommés au lieu de l'interpolation dans la query.

### Workflow 3 : `GET /webhook/articles/matches`

Retourne les articles super-likés.

**Nœuds :**

1. **Webhook Trigger**
   - HTTP Method : GET
   - Path : `articles/matches`

2. **PostgreSQL** (Execute Query)
   ```sql
   SELECT id, article_id, titre_fr, url, resume_fr, volet, pertinence, tags, langue_source, created_at::text
   FROM matches
   LIMIT 100;
   ```

3. **Respond to Webhook**
   - Response Body : `{{ $items().map(i => i.json) }}`

## 4. Activer les workflows

Pour chaque workflow webhook : clique **Publish** en haut à droite. Sans ça, les URLs renverront 404.

## 5. Tester depuis le réseau VPN

Depuis un terminal connecté à ton VPN :

```bash
# Doit retourner [] ou la liste d'articles
curl http://10.8.0.201:5678/webhook/articles/pending

# Tester un feedback
curl -X POST http://10.8.0.201:5678/webhook/feedback \
  -H "Content-Type: application/json" \
  -d '{"article_id":"abc123","action":"super_like"}'

# Tester les matches
curl http://10.8.0.201:5678/webhook/articles/matches
```

## 6. URL à mettre dans l'app iOS

Au premier lancement de l'app, configure l'URL **sans** le path `/webhook/...` :

```
http://10.8.0.201:5678
```

L'app ajoutera elle-même `/webhook/articles/pending`, etc.

## 7. (Optionnel) Authentification

Si tu veux ajouter une couche d'auth simple, dans chaque webhook n8n :

- Active **Authentication** → "Header Auth"
- Crée un credential avec :
  - Name: `X-API-Key`
  - Value: une chaîne aléatoire longue

Puis dans l'app iOS, configure cette même chaîne dans le champ "Clé API" au premier lancement.
