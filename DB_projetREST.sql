CREATE DATABASE IF NOT EXISTS projet_rest;
USE projet_rest;

-- 1. TABLE SALLES
CREATE TABLE salles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    ville VARCHAR(100) NOT NULL DEFAULT 'Paris',
    capacite INT NOT NULL
);

-- 2. TABLE USERS (Propriétaire de Film)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('proprietaire_film', 'client') NOT NULL DEFAULT 'client',
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLE FILMS (Maintenant lié à un propriétaire de film)
CREATE TABLE films (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    duree INT NOT NULL,
    langue VARCHAR(50) NOT NULL,
    sous_titres VARCHAR(50),
    realisateur VARCHAR(150),
    age_minimum INT DEFAULT 0,
    description_film VARCHAR(1000),
    user_id INT NOT NULL, -- Clé étrangère vers le propriétaire du film
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- 4. TABLES ACTEURS
CREATE TABLE acteurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL
);

CREATE TABLE acteur_film (
    id INT AUTO_INCREMENT PRIMARY KEY,
    film_id INT NOT NULL,
    acteur_id INT NOT NULL,
    
    FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
    FOREIGN KEY (acteur_id) REFERENCES acteurs(id) ON DELETE CASCADE,
    UNIQUE KEY uc_acteur_film (film_id, acteur_id)
);

-- 5. TABLE PROGRAMMATION_SEANCE
CREATE TABLE programmation_seance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    film_id INT NOT NULL,
    salle_id INT NOT NULL,
    date_seance DATE NOT NULL,
    heure_debut TIME NOT NULL,
    
    FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
    FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE CASCADE,
    UNIQUE KEY uc_seance (salle_id, date_seance, heure_debut)
);

-- 6. TABLE AVIS
CREATE TABLE avis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    film_id INT NOT NULL,
    note INT NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire TEXT,
    date_avis DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE
);

