-- Script di inizializzazione del database LAMP
-- Questo script viene eseguito automaticamente al primo avvio di MariaDB

-- Crea il database se non esiste
CREATE DATABASE IF NOT EXISTS lamp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Usa il database
USE lamp_db;

-- Crea una tabella di esempio per gli utenti
CREATE TABLE IF NOT EXISTS utenti (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    data_registrazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_accesso TIMESTAMP NULL,
    attivo BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_data_registrazione (data_registrazione)
);

-- Crea una tabella per i post di un blog di esempio
CREATE TABLE IF NOT EXISTS post (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titolo VARCHAR(200) NOT NULL,
    contenuto TEXT NOT NULL,
    autore_id INT,
    data_pubblicazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_modifica TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    pubblicato BOOLEAN DEFAULT FALSE,
    visualizzazioni INT DEFAULT 0,
    FOREIGN KEY (autore_id) REFERENCES utenti(id) ON DELETE SET NULL,
    INDEX idx_data_pubblicazione (data_pubblicazione),
    INDEX idx_autore (autore_id)
);

-- Crea una tabella per i commenti
CREATE TABLE IF NOT EXISTS commenti (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    utente_id INT,
    contenuto TEXT NOT NULL,
    data_commento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approvato BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE,
    FOREIGN KEY (utente_id) REFERENCES utenti(id) ON DELETE SET NULL,
    INDEX idx_post (post_id),
    INDEX idx_data_commento (data_commento)
);

-- Inserisci alcuni dati di esempio
INSERT INTO utenti (nome, cognome, email, password_hash) VALUES
('Mario', 'Rossi', 'mario.rossi@example.com', SHA2('password123', 256)),
('Laura', 'Bianchi', 'laura.bianchi@example.com', SHA2('password456', 256)),
('Giuseppe', 'Verdi', 'giuseppe.verdi@example.com', SHA2('password789', 256));

INSERT INTO post (titolo, contenuto, autore_id, pubblicato) VALUES
('Benvenuto nel nostro blog!', 'Questo è il primo post del nostro blog LAMP. Qui troverai articoli interessanti su sviluppo web, PHP, MySQL e molto altro.', 1, TRUE),
('Guida a Docker e LAMP Stack', 'Docker è una tecnologia fantastica per creare ambienti di sviluppo isolati e riproducibili. In questo articolo vedremo come configurare uno stack LAMP.', 2, TRUE),
('Best Practices per PHP', 'Sviluppare in PHP moderno richiede l\'adozione di best practices specifiche. Vediamo insieme le più importanti.', 3, FALSE);

INSERT INTO commenti (post_id, utente_id, contenuto, approvato) VALUES
(1, 2, 'Ottimo post! Non vedo l\'ora di leggere i prossimi articoli.', TRUE),
(1, 3, 'Benvenuto anche da parte mia! Questo blog sembra molto promettente.', TRUE),
(2, 1, 'Docker è davvero potente. Grazie per la guida!', TRUE);

-- Crea un utente con privilegi limitati per l'applicazione
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'app_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON lamp_db.* TO 'app_user'@'%';
FLUSH PRIVILEGES;

-- Mostra un riepilogo delle tabelle create
SELECT 
    TABLE_NAME as 'Tabella',
    TABLE_ROWS as 'Righe',
    CREATE_TIME as 'Data Creazione'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'lamp_db'
ORDER BY TABLE_NAME;
