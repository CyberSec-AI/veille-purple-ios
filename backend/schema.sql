-- =====================================================
-- Veille Purple Team — PostgreSQL schema
-- À exécuter dans la base PostgreSQL liée à n8n (via Coolify)
-- =====================================================

-- Table : articles ingérés depuis n8n après filtrage Gemini
CREATE TABLE IF NOT EXISTS articles (
    id              SERIAL PRIMARY KEY,
    article_id      VARCHAR(64) UNIQUE NOT NULL,   -- hash MD5 de l'URL pour dédoublonnage
    titre_fr        TEXT NOT NULL,
    url             TEXT NOT NULL,
    resume_fr       TEXT NOT NULL,
    volet           VARCHAR(20) NOT NULL,           -- offensif | RE | purple
    pertinence      VARCHAR(20) NOT NULL,           -- haute | moyenne
    tags            TEXT[] DEFAULT '{}',
    langue_source   VARCHAR(10),
    created_at      TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    swiped_at       TIMESTAMPTZ NULL                -- NULL = pas encore swipé
);

-- Index pour récupérer rapidement les articles non-swipés
CREATE INDEX IF NOT EXISTS idx_articles_pending
    ON articles(swiped_at, created_at DESC)
    WHERE swiped_at IS NULL;

-- Index pour rechercher par volet
CREATE INDEX IF NOT EXISTS idx_articles_volet ON articles(volet);

-- Table : feedbacks utilisateur (les swipes)
CREATE TABLE IF NOT EXISTS feedbacks (
    id              SERIAL PRIMARY KEY,
    article_id      VARCHAR(64) NOT NULL REFERENCES articles(article_id) ON DELETE CASCADE,
    action          VARCHAR(20) NOT NULL,           -- pass | like | super_like
    created_at      TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_feedbacks_article ON feedbacks(article_id);
CREATE INDEX IF NOT EXISTS idx_feedbacks_action ON feedbacks(action);

-- Vue pratique : super-likes (matches)
CREATE OR REPLACE VIEW matches AS
SELECT a.*, f.created_at AS liked_at
FROM articles a
INNER JOIN feedbacks f ON a.article_id = f.article_id
WHERE f.action = 'super_like'
ORDER BY f.created_at DESC;

-- Vue pratique : statistiques de swipe pour le futur fine-tuning IA
CREATE OR REPLACE VIEW feedback_stats AS
SELECT
    a.volet,
    f.action,
    COUNT(*) AS nb,
    AVG(CASE WHEN f.action = 'super_like' THEN 1.0
             WHEN f.action = 'like' THEN 0.7
             ELSE 0.0 END) AS preference_score
FROM articles a
INNER JOIN feedbacks f ON a.article_id = f.article_id
GROUP BY a.volet, f.action;

-- Migration V2 : ajout source_type pour la veille radar
ALTER TABLE articles
    ADD COLUMN IF NOT EXISTS source_type VARCHAR(10) NOT NULL DEFAULT 'cible';

CREATE INDEX IF NOT EXISTS idx_articles_source_type
    ON articles(source_type);