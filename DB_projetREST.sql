---------------------------------------------------------
-- SQL COMPLET DU PROJET REST
---------------------------------------------------------

-- 1. Configuration et création de la base de données
CREATE DATABASE IF NOT EXISTS cinema_project;
USE cinema_project;

-- Désactiver la vérification des clés étrangères (pour les insertions et TRUNCATE)
SET FOREIGN_KEY_CHECKS = 0;

-- Effacement des tables existantes pour garantir un état propre (à exécuter si les tables existent déjà)
DROP TABLE IF EXISTS avis;
DROP TABLE IF EXISTS programmation_seance;
DROP TABLE IF EXISTS acteur_film;
DROP TABLE IF EXISTS acteurs;
DROP TABLE IF EXISTS films;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS salles;

-- 2. Création des tables

-- TABLE SALLES
CREATE TABLE salles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    ville VARCHAR(100) NOT NULL DEFAULT 'Paris',
    capacite INT NOT NULL
);

-- TABLE USERS (Intègre les trois rôles : admin, proprietaire_film, client)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'proprietaire_film', 'client') NOT NULL DEFAULT 'client',
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLE FILMS (Lié au propriétaire qui l'a publié)
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

-- TABLES ACTEURS
CREATE TABLE acteurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL
);

-- TABLE D'ASSOCIATION ACTEUR_FILM (Relation N-N)
CREATE TABLE acteur_film (
    id INT AUTO_INCREMENT PRIMARY KEY,
    film_id INT NOT NULL,
    acteur_id INT NOT NULL,
    
    FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
    FOREIGN KEY (acteur_id) REFERENCES acteurs(id) ON DELETE CASCADE,
    UNIQUE KEY uc_acteur_film (film_id, acteur_id)
);

-- TABLE PROGRAMMATION_SEANCE (Séances réelles)
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

-- TABLE AVIS
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

-- 3. Insertion des données (40 FILMS - 3 Max par franchise)

-- USERS (5 utilisateurs, dont un admin)
INSERT INTO users (id, username, email, password, role) VALUES
(1, 'owner_shonen_A', 'shonen_A@test.com', 'shonen123', 'proprietaire_film'),
(2, 'owner_shonen_B', 'shonen_B@test.com', 'shonen456', 'proprietaire_film'),
(3, 'owner_ghibli', 'ghibli@test.com', 'ghibli789', 'proprietaire_film'),
(4, 'simple_client', 'client@test.com', 'client999', 'client'),
(5, 'super_admin', 'admin@cinema.com', 'admin_secure_pwd', 'admin');

-- SALLES (10 Cinémas Parisiens)
INSERT INTO salles (id, nom, adresse, ville, capacite) VALUES
(1, 'Le Grand Rex Anime', '1 Boulevard Poissonnière', 'Paris', 800),
(2, 'UGC Ciné Cité Les Halles', '7 Place de la Rotonde', 'Paris', 450),
(3, 'Pathé Beaugrenelle', '7 Rue Linois', 'Paris', 300),
(4, 'Cinéma du Panthéon', '13 Rue Victor Cousin', 'Paris', 150),
(5, 'Gaumont Alésia', '73 Avenue du Général Leclerc', 'Paris', 350),
(6, 'L\'Arlequin', '76 Rue du Cherche-Midi', 'Paris', 200),
(7, 'MK2 Bibliothèque', '128-162 Avenue de France', 'Paris', 400),
(8, 'Cinéma Etoile Lilas', 'Place du Maquis du Vercors', 'Paris', 250),
(9, 'Studio 28', '10 Rue Tholozé', 'Paris', 120),
(10, 'Le Max Linder Panorama', '24 Boulevard Poissonnière', 'Paris', 500);

-- FILMS (40 Animes)
INSERT INTO films (id, titre, duree, langue, sous_titres, realisateur, age_minimum, description_film, user_id) VALUES
-- Franchises (Owner ID: 1)
(1, 'Demon Slayer : Le Train de l\'Infini', 117, 'VO', 'Français', 'Haruo Sotozaki', 12, 'Tanjiro et ses compagnons se lancent dans une nouvelle mission à bord du Train de l\'Infini.', 1),
(2, 'Demon Slayer : Vers l\'Entraînement des Piliers', 103, 'VO', 'Français', 'Haruo Sotozaki', 12, 'Compilation des derniers épisodes pour le lancement de la saison suivante.', 1),
(3, 'Jujutsu Kaisen 0', 105, 'VO', 'Français', 'Sunghoo Park', 12, 'L\'histoire de Yuta Okkotsu et de l\'esprit de son amie d\'enfance, Rika.', 1),
(4, 'One Piece Film: Red', 115, 'VF', NULL, 'Gorō Taniguchi', 10, 'L\'équipage de Chapeau de paille assiste au concert de la chanteuse Uta, fille de Shanks.', 1),
(5, 'One Piece Stampede', 101, 'VO', 'Français', 'Takashi Otsuka', 10, 'Luffy et les pirates participent au Festival des Pirates.', 1),
(6, 'Dragon Ball Super: Super Hero', 99, 'VF', NULL, 'Tetsuro Kodama', 8, 'L\'armée du Ruban Rouge fait son retour avec de nouveaux androïdes.', 1),
(7, 'Dragon Ball Super: Broly', 100, 'VF', NULL, 'Tatsuya Nagamine', 8, 'Goku et Vegeta rencontrent le Saiyan légendaire Broly.', 1),
(8, 'My Hero Academia: World Heroes\' Mission', 104, 'VO', 'Français', 'Kenji Nagasaki', 10, 'Deku et ses camarades sont accusés d\'un crime et doivent sauver le monde.', 1),
(9, 'My Hero Academia: Two Heroes', 96, 'VF', NULL, 'Kenji Nagasaki', 10, 'Deku et All Might visitent une île scientifique.', 1),
(10, 'Haikyu!! La bataille finale', 85, 'VO', 'Français', 'Susumu Mitsunaka', 6, 'Le match tant attendu entre Karasuno et Nekoma.', 1),
(11, 'Kuroko\'s Basket Last Game', 90, 'VF', NULL, 'Shunsuke Tada', 6, 'L\'équipe de la Génération des Miracles se réunit pour affronter l\'équipe américaine, Jabberwock.', 1),
(12, 'The First Slam Dunk', 124, 'VO', 'Français', 'Takehiko Inoue', 10, 'Ryota Miyagi et l\'équipe de Shohoku affrontent la puissante Sannoh Kogyo.', 1),
(13, 'Naruto Shippuden: Road to Ninja', 109, 'VF', NULL, 'Hayato Date', 10, 'Naruto et Sakura sont transportés dans un monde alternatif par Tobi.', 1),
(14, 'Boruto: Naruto, le film', 96, 'VO', 'Français', 'Hiroyuki Yamashita', 8, 'Boruto, le fils de Naruto, participe à l\'examen Chunin.', 1),
(15, 'Bleach: Hell Verse', 94, 'VF', NULL, 'Noriyuki Abe', 14, 'Ichigo pénètre dans les enfers pour sauver sa sœur kidnappée.', 1),
(16, 'Bleach: The DiamondDust Rebellion', 92, 'VF', NULL, 'Noriyuki Abe', 12, 'Le capitaine Toshiro Hitsugaya est accusé d\'avoir volé un artefact.', 1),
-- Shinkai et Blockbusters (Owner ID: 2)
(17, 'Your Name.', 106, 'VO', 'Français', 'Makoto Shinkai', 8, 'Un garçon et une fille échangent leurs corps.', 2),
(18, 'Weathering with You', 112, 'VO', 'Français', 'Makoto Shinkai', 8, 'Un lycéen fugueur rencontre une fille capable de contrôler le temps.', 2),
(19, 'Suzume', 122, 'VO', 'Français', 'Makoto Shinkai', 8, 'Une jeune fille voyage à travers le Japon pour fermer des portes mystérieuses.', 2),
(20, 'Akira', 124, 'VF', NULL, 'Katsuhiro Otomo', 16, 'Dans un Tokyo futuriste, la guerre des gangs mène à l\'éveil d\'un pouvoir psychique dévastateur.', 2),
(21, 'Ghost in the Shell', 83, 'VO', 'Français', 'Mamoru Oshii', 16, 'Un cyborg policier enquête sur un cybercriminel.', 2),
(22, 'Promare', 111, 'VO', 'Français', 'Hiroyuki Imaishi', 12, 'Des pompiers futuristes combattent des mutants pyrokinésiques.', 2),
(23, 'Sword Art Online Progressive: Aria of a Starless Night', 97, 'VO', 'Français', 'Ayako Kōno', 10, 'Retour sur les débuts du jeu mortel Aincrad.', 2),
(24, 'Code Geass: Lelouch of the Re;surrection', 112, 'VF', NULL, 'Gorō Taniguchi', 12, 'Dix ans après la mort de Lelouch, la paix est brisée.', 2),
(25, 'Fate/stay night: Heaven\'s Feel III. spring song', 122, 'VO', 'Français', 'Tomonori Sudō', 16, 'Le dernier film de la trilogie Heaven\'s Feel.', 2),
(26, 'Psycho-Pass : Le Film', 113, 'VO', 'Français', 'Naoyoshi Shiotani', 16, 'L\'inspectrice Akane Tsunemori se rend à l\'étranger.', 2),
(27, 'Lupin III: The First', 93, 'VF', NULL, 'Takashi Yamazaki', 8, 'Le célèbre voleur Lupin III se lance à la recherche du journal de Bresson.', 2),
(28, 'Cowboy Bebop : Le Film', 115, 'VF', NULL, 'Shinichirō Watanabe', 12, 'L\'équipage du Bebop traque un terroriste.', 2),
-- Classiques Ghibli/Kon/Hosoda (Owner ID: 3)
(29, 'Le Voyage de Chihiro', 125, 'VO', 'Français', 'Hayao Miyazaki', 6, 'Une fillette se retrouve dans le monde des esprits.', 3),
(30, 'Princesse Mononoké', 134, 'VF', NULL, 'Hayao Miyazaki', 10, 'Un prince maudit se retrouve impliqué dans un conflit entre les esprits de la forêt.', 3),
(31, 'Mon Voisin Totoro', 86, 'VF', NULL, 'Hayao Miyazaki', 3, 'Deux jeunes filles découvrent les créatures magiques Totoro.', 3),
(32, 'Le Château ambulant', 119, 'VO', 'Français', 'Hayao Miyazaki', 6, 'Une jeune fille transformée en vieille femme doit vivre avec un magicien.', 3),
(33, 'Paprika', 90, 'VO', 'Français', 'Satoshi Kon', 12, 'Des scientifiques utilisent une technologie pour entrer dans les rêves.', 3),
(34, 'Perfect Blue', 81, 'VO', 'Français', 'Satoshi Kon', 16, 'Une ancienne idole de la J-Pop se lance dans une carrière d\'actrice.', 3),
(35, 'Les Enfants Loups, Ame & Yuki', 117, 'VF', NULL, 'Mamoru Hosoda', 8, 'L\'histoire d\'une femme élevant seule ses deux enfants qui sont à moitié loups.', 3),
(36, 'Mirai, ma petite sœur', 98, 'VF', NULL, 'Mamoru Hosoda', 6, 'Un jeune garçon se sent négligé après la naissance de sa petite sœur.', 3),
(37, 'A Silent Voice', 130, 'VO', 'Français', 'Naoko Yamada', 12, 'Un garçon se lie d\'amitié avec une fille sourde qu\'il a harcelée dans son enfance.', 3),
(38, 'The Girl Who Leapt Through Time', 98, 'VO', 'Français', 'Mamoru Hosoda', 10, 'Une lycéenne découvre qu\'elle peut voyager dans le temps.', 3),
(39, 'Evangelion: 3.0 + 1.0 Thrice Upon a Time', 155, 'VO', 'Français', 'Hideaki Anno', 12, 'Le dernier volet de la saga Rebuild of Evangelion.', 3),
(40, 'Made in Abyss: Dawn of the Deep Soul', 102, 'VO', 'Français', 'Masayuki Kojima', 16, 'Riko et Reg rencontrent le mystérieux Bondrewd.', 3);

-- ACTEURS (Seiyū)
INSERT INTO acteurs (id, nom) VALUES
(1, 'Natsuki Hanae'), (2, 'Akari Kitō'), (3, 'Hiro Shimono'), (4, 'Kensho Ono'), (5, 'Mayumi Tanaka'),
(6, 'Kazuya Nakai'), (7, 'Yuki Kaji'), (8, 'Daisuke Ono'), (9, 'Yuichi Nakamura'), (10, 'Masako Nozawa'),
(11, 'Ryō Horikawa'), (12, 'Junko Takeuchi'), (13, 'Noriaki Sugiyama'), (14, 'Masakazu Morita'), (15, 'Fumiko Orikasa'),
(16, 'Miyu Irino'), (17, 'Mari Natsuki'), (18, 'Rumi Hiiragi'), (19, 'Ryunosuke Kamiki'), (20, 'Mone Kamishiraishi'),
(21, 'Minami Hamabe'), (22, 'Takumi Kitamura'), (23, 'Mamoru Miyano'), (24, 'Aoi Yūki'), (25, 'Megumi Ogata'),
(26, 'Maaya Sakamoto'), (27, 'Yūko Sanpei'), (28, 'Daisuke Sakaguchi'), (29, 'Minako Kotobuki'), (30, 'Saori Hayami');

-- ACTEUR_FILM (Liens)
INSERT INTO acteur_film (film_id, acteur_id) VALUES
(1, 1), (1, 2), (1, 3), (3, 4), (4, 5), (4, 6), (6, 10), (7, 11), (8, 7), (9, 8), (10, 9), (11, 4), (12, 10), (13, 12), (14, 27), (15, 14), (16, 15),
(17, 19), (18, 20), (19, 21), (20, 22), (21, 23), (22, 24), (23, 25), (24, 26), (25, 27), (26, 23), (27, 10), (28, 5), (28, 26),
(29, 16), (30, 17), (31, 18), (32, 19), (33, 20), (34, 21), (35, 27), (36, 12), (37, 13), (38, 19), (39, 25), (40, 24);

-- PROGRAMMATION_SEANCE (60 Séances réelles sur 7 jours)
INSERT INTO programmation_seance (film_id, salle_id, date_seance, heure_debut) VALUES
(1, 1, '2026-03-01', '19:30:00'), (17, 3, '2026-03-01', '21:00:00'), (6, 5, '2026-03-01', '17:00:00'), (3, 7, '2026-03-01', '20:00:00'), (4, 2, '2026-03-01', '18:00:00'),
(1, 2, '2026-03-02', '18:45:00'), (4, 4, '2026-03-02', '22:00:00'), (18, 6, '2026-03-02', '16:30:00'), (8, 8, '2026-03-02', '20:15:00'), (15, 10, '2026-03-02', '19:45:00'),
(6, 1, '2026-03-03', '14:00:00'), (1, 3, '2026-03-03', '16:30:00'), (4, 5, '2026-03-03', '19:00:00'), (19, 7, '2026-03-03', '21:30:00'), (31, 9, '2026-03-03', '10:30:00'),
(10, 2, '2026-03-03', '18:00:00'), (12, 4, '2026-03-03', '15:00:00'), (13, 6, '2026-03-03', '20:30:00'),
(17, 4, '2026-03-04', '18:00:00'), (1, 6, '2026-03-04', '20:45:00'), (7, 8, '2026-03-04', '19:15:00'), (11, 10, '2026-03-04', '21:00:00'), (20, 1, '2026-03-04', '22:30:00'),
(16, 3, '2026-03-04', '17:00:00'), (21, 5, '2026-03-04', '19:45:00'),
(4, 2, '2026-03-05', '19:30:00'), (6, 4, '2026-03-05', '21:15:00'), (1, 5, '2026-03-05', '23:00:00'), (22, 7, '2026-03-05', '20:45:00'), (23, 9, '2026-03-05', '18:00:00'),
(32, 3, '2026-03-05', '17:45:00'), (14, 10, '2026-03-05', '20:00:00'),
(17, 1, '2026-03-06', '14:00:00'), (1, 3, '2026-03-06', '17:30:00'), (4, 5, '2026-03-06', '20:00:00'), (6, 7, '2026-03-06', '11:00:00'), (24, 10, '2026-03-06', '16:00:00'),
(12, 2, '2026-03-06', '19:00:00'), (25, 4, '2026-03-06', '15:45:00'), (33, 6, '2026-03-06', '21:45:00'), (8, 8, '2026-03-06', '14:30:00'), (2, 9, '2026-03-06', '17:00:00'),
(1, 8, '2026-03-07', '15:00:00'), (17, 10, '2026-03-07', '18:30:00'), (4, 6, '2026-03-07', '17:00:00'), (6, 9, '2026-03-07', '14:45:00'), (2, 5, '2026-03-07', '20:30:00'),
(15, 1, '2026-03-07', '19:00:00'), (5, 4, '2026-03-07', '21:30:00'), (30, 3, '2026-03-07', '16:00:00'), (26, 7, '2026-03-07', '18:45:00'), (11, 2, '2026-03-07', '17:30:00');

-- Réactiver la vérification des clés étrangères
SET FOREIGN_KEY_CHECKS = 1;
