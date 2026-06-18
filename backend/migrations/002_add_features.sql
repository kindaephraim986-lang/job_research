-- ============================================
-- Migration 002: Ajouter les 4 fonctionnalités
-- ============================================

-- 1. Table pour les photos de profil des candidats (persistance + historique)
CREATE TABLE IF NOT EXISTS profile_photos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    candidat_id INT NOT NULL,
    photo_url VARCHAR(500),
    photo_filename VARCHAR(255),
    photo_bytes LONGBLOB,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (candidat_id) REFERENCES candidats(id) ON DELETE CASCADE,
    INDEX idx_candidat_is_current (candidat_id, is_current)
);

-- 2. Table pour les notifications
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    user_type ENUM('candidat', 'entreprise') NOT NULL,
    type ENUM('offer', 'message', 'application_update', 'subscription', 'document_access') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    related_id INT,
    related_type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES candidats(id) ON DELETE CASCADE,
    INDEX idx_user_is_read (user_id, is_read),
    INDEX idx_created_at (created_at)
);

-- 3. Table pour les URLs signées des documents (sécurité)
CREATE TABLE IF NOT EXISTS signed_file_urls (
    id INT PRIMARY KEY AUTO_INCREMENT,
    document_id INT NOT NULL,
    document_type ENUM('cv', 'cnib_recto', 'cnib_verso', 'photo') NOT NULL,
    user_id INT NOT NULL,
    access_token VARCHAR(255) UNIQUE NOT NULL,
    requester_id INT,
    requester_type ENUM('candidat', 'entreprise'),
    expires_at TIMESTAMP NOT NULL,
    accessed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES candidats(id) ON DELETE CASCADE,
    FOREIGN KEY (requester_id) REFERENCES entreprises(id) ON DELETE SET NULL,
    INDEX idx_token (access_token),
    INDEX idx_expires_at (expires_at)
);

-- 4. Table pour les logs d'accès aux documents (audit)
CREATE TABLE IF NOT EXISTS document_access_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    document_id INT NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    candidat_id INT NOT NULL,
    entreprise_id INT,
    access_type ENUM('view', 'download', 'blocked') NOT NULL,
    blocked_reason VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidat_id) REFERENCES candidats(id) ON DELETE CASCADE,
    FOREIGN KEY (entreprise_id) REFERENCES entreprises(id) ON DELETE SET NULL,
    INDEX idx_candidat_accessed_at (candidat_id, accessed_at)
);

-- 5. Ajouter colonne pour store photo_url et cache buster dans candidats
ALTER TABLE candidats ADD COLUMN IF NOT EXISTS profile_photo_url VARCHAR(500);
ALTER TABLE candidats ADD COLUMN IF NOT EXISTS photo_cache_buster VARCHAR(50);

-- 6. Ajouter colonnes pour l'historique des photos dans candidats
ALTER TABLE candidats ADD COLUMN IF NOT EXISTS last_photo_update TIMESTAMP NULL;

-- 7. Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_notifications_user_type ON notifications(user_id, user_type);
CREATE INDEX IF NOT EXISTS idx_profile_photos_candidat ON profile_photos(candidat_id);
