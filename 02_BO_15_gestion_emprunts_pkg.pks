CREATE OR REPLACE PACKAGE gestion_emprunts_pkg IS
    TYPE t_info_livre IS RECORD (
        id                bo.livres.id%TYPE,
        titre             bo.livres.titre%TYPE,
        isbn              bo.livres.isbn%TYPE,
        auteur            bo.auteurs.nom_auteur%TYPE,
        maison_edition    bo.livres.maison_edition%TYPE,
        annee_publication bo.livres.annee_publication%TYPE,
        langage           bo.livres.langage%TYPE,
        nom_section       bo.sections.nom%TYPE,
        nom_genre         bo.genres.nom_genre%TYPE,
        prix              bo.livres.prix%TYPE
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
    i_id_membre IN NUMBER,
    o_montant   OUT NUMBER
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
    -- i_id_livre(number) : id du livre (IN)
    --0_date_retour_prevue : Date de retour (OUT)
    -- RETOUR:
    --BOOLEAN : True si livre disponible sinon false.
    --
    -- EXCEPTIONS :
    --  e_livre_indisponible : Si livre non disponible.
    FUNCTION est_disponible_fct(
        i_id_livre IN NUMBER,
        o_date_retour_prevue OUT DATE
)   RETURN BOOLEAN;

    -- Procédure D: retourner_livre_fct
    --
    -- BUT : Recherche et modifie la valeur de retour dans l'enregistrement
    --
    -- PARAMETRES :
    --  id_membre (IN NUMBER) : id du membre
    --  id_livre (IN NUMBER): id du livre
    --
    -- EXCEPTIONS :
    --  e_livre_indisponible : si le livre est pas dispo
PROCEDURE retourner_livre_prc(
        id_membre IN NUMBER,
        id_livre  IN NUMBER
    );

    -- Fonction E : rechercher_livre_fct
    --
    -- BUT : Recherche un livre selon l'id et retourne toutes ses infos dans un record
    --
    -- PARAMÈTRES :
    -- io_id_livre (number) : id du livre à rechercher
    --
    -- RETOUR :
    -- t_info_livre : record avec toutes les infos du livre, ou return 0 plus null
    --
    -- EXCEPTIONS :
    -- no_data_found : si aucun livre trouvé, retourne id = 0 et null
  FUNCTION rechercher_livre_fct(
        io_id_livre IN OUT NUMBER)
      RETURN t_info_livre;

    -- procédure F : archiver_prc
    --
    -- BUT : d'archiver les emprunts par mois et par années dans de nouvelles tables
    -- le nom des tables va être selon l'année et le mois (bo.emprunts_archive_202001)
    --
    -- PARAMÈTRES :
    -- p_annee : l'annee courant par défaut
    -- p_annee : et le mois courant par défaut
    -- EXCEPTIONS :
    -- message d'erreur si ça fonctionne pas
    PROCEDURE archiver_prc(
        p_annee IN NUMBER DEFAULT g_annee_courante,
        p_mois  IN NUMBER DEFAULT g_mois_courant
    );

END gestion_emprunts_pkg;