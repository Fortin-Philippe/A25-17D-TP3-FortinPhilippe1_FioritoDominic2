CREATE OR REPLACE PACKAGE BO_10_gestion_emprunts_pkg IS
        TYPE t_info_livre IS RECORD (
        id                NUMBER,
        titre             VARCHAR2(100),
        isbn              VARCHAR2(50),
        auteur            VARCHAR2(100),
        maison_edition    VARCHAR2(100),
        annee_publication NUMBER(4),
        langage           VARCHAR2(50),
        nom_section       VARCHAR2(100),
        nom_genre         VARCHAR2(50)
    );
    g_annee_courante VARCHAR2(4) := '2020';
    g_mois_courant   VARCHAR2(2) := '12';
    e_livre_indisponible EXCEPTION;
    e_penalites_impayees EXCEPTION;
    -- Fonction A : est_penalites_impayees_fct
    --
    -- BUT : Vérifier si un membre à des frais à payer.
    --
    -- PARAMÈTRES :
    -- id_membre (number) : id du membre
    -- montant (number) : montant total des frais
    --
    -- RETOUR:
    --BOOLEAN : True si membre a des frais sinon False.
    --
    -- EXCEPTIONS :
    -- e_penalites_impayees: si le membre a ou a eu des retards

    FUNCTION est_penalites_impayees_fct(
        id_membre IN NUMBER,
    -- 	e_penalites_impayees :
        montant OUT NUMBER
    ) RETURN BOOLEAN;
    -- Procédure B : emprunter_livre_prc
    --
    -- BUT : Permet à un membre d'emprunter un livre
    --
    -- PARAMÈTRES :
    -- id_membre (number) : id du membre
    -- id_livre (number) : id du livre

    PROCEDURE emprunter_livre_prc(
        id_membre IN NUMBER,
        id_livre  IN NUMBER
    );
    -- Fonction C : est_disponible_fct
    --
    -- BUT : Vérifie si le livre est disponible
    --
    -- PARAMÈTRES :
    -- id_livre(number) : id du livre
    --
    -- RETOUR:
    --BOOLEAN : True si livre disponible sinon false.
    --
    -- EXCEPTIONS :
    --  e_livre_indisponible : Si livre non disponible.
    PROCEDURE retourner_livre_prc(
        id_membre IN NUMBER,
        id_livre  IN NUMBER
    );
    -- Procédure : est_disponible_fct
    --
    -- BUT : Vérifie si le livre est dispo pour emprunt aujourd'hui
    --
    -- PARAMETRES :
    --  id_livre (IN NUMBER) : id du livre qu'on veut checker
    --  date_retour_prevue (OUT DATE) : date prévue du retour si le livre est déjà emprunté
    --
    -- RETOUR :
    --  BOOLEAN : TRUE si le livre est dispo, FALSE sinon
    --
    -- EXCEPTIONS :
    --  e_livre_indisponible : si le livre est pas dispo


    FUNCTION rechercher_livre_fct(
        id_livre IN OUT NUMBER
    ) RETURN t_info_livre;
    -- Fonction E : rechercher_livre_fct
    --
    -- BUT : Recherche un livre selon l'id et retourne toutes ses infos dans un record
    --
    -- PARAMÈTRES :
    -- id_livre (number) : id du livre à rechercher
    --
    -- RETOUR :
    -- t_info_livre : record avec toutes les infos du livre, ou return 0 plus null
    --
    -- EXCEPTIONS :
    -- no_data_found : si aucun livre trouvé, retourne id = 0 et null

    -- avec la création de mon record ici
     TYPE t_info_livre IS RECORD (
        sections_id      livre.sections_id%TYPE,
        auteurs_id       livre.auteurs_id%TYPE,
        genres_id        livre.genres_id%TYPE,
        isbn             livre.isbn%TYPE,
        titre            livre.titre%TYPE,
        maison_edition   livre.maison_edition%TYPE,
        annee_publication livre.annee_publication%TYPE,
        langage          livre.langage%TYPE,
        prix             livre.prix%TYPE
    );

    -- procédure F : archiver_prc
    --
    -- BUT : d'archiver les emprunts par mois et par années dans de nouvelles tables
    -- le nom des tables va être selon l'année et le mois (bo.emprunts_archive_202001)
    --
    -- PARAMÈTRES :
    -- p_annee : l'anee courant par défaut
    -- p_annee : et le mois courant par défaut
    --
    -- RETOUR :
    -- juste une message que la table à été créer ou non
    --
    -- EXCEPTIONS :
    -- message d'erreur si ça fonctionne pas
    PROCEDURE archiver_prc(
        p_annee IN NUMBER DEFAULT g_annee_courante,
        p_mois  IN NUMBER DEFAULT g_mois_courant
    );

