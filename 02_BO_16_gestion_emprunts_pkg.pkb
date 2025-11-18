CREATE OR REPLACE PACKAGE BODY gestion_emprunts_pkg IS

    FUNCTION est_penalites_impayees_fct(
        i_id_membre IN NUMBER,
        o_montant   OUT NUMBER
    ) RETURN BOOLEAN IS
        v_montant NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(
                   CASE
                       WHEN TRUNC(SYSDATE) > date_retour_prevu
                       THEN TRUNC(SYSDATE) - date_retour_prevu
                       ELSE 0
                   END
               ),0)
        INTO v_montant
        FROM bo.emprunts
        WHERE membres_id = i_id_membre
          AND date_retour IS NULL;

        o_montant := v_montant;
        RETURN (v_montant > 0);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue dans est_penalites_impayees_fct : '||SQLERRM);
            o_montant := 0;
            RETURN FALSE;
    END est_penalites_impayees_fct;

    PROCEDURE emprunter_livre_prc(
        id_membre IN NUMBER,
        id_livre  IN NUMBER
    ) IS
        v_montant NUMBER;
        v_penalites BOOLEAN;
        v_dispo BOOLEAN;
        v_date_retour_prevue DATE;
    BEGIN
        v_penalites := est_penalites_impayees_fct(id_membre, v_montant);
        IF v_penalites THEN
            RAISE e_penalites_impayees;
        END IF;

        v_dispo := est_disponible_fct(id_livre, v_date_retour_prevue);
        IF NOT v_dispo THEN
            RAISE e_livre_indisponible;
        END IF;

        INSERT INTO bo.emprunts(livres_id, membres_id, date_emprunt, date_retour_prevu)
        VALUES(id_livre, id_membre, SYSDATE, SYSDATE + 14);

        DBMS_OUTPUT.PUT_LINE('Livre '||id_livre||' emprunté par membre '||id_membre);

    EXCEPTION
        WHEN e_penalites_impayees THEN
            DBMS_OUTPUT.PUT_LINE('Emprunt refusé : pénalités impayées pour membre '||id_membre);
        WHEN e_livre_indisponible THEN
            DBMS_OUTPUT.PUT_LINE('Emprunt refusé : livre '||id_livre||' indisponible');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue dans emprunter_livre_prc : '||SQLERRM);
    END emprunter_livre_prc;

FUNCTION est_disponible_fct(
    i_id_livre IN NUMBER,
    o_date_retour_prevue OUT DATE
) RETURN BOOLEAN IS
    v_nb_emprunts_actifs NUMBER := 0;
BEGIN
    SELECT MIN(date_retour_prevu)
    INTO o_date_retour_prevue
    FROM bo.emprunts
    WHERE livres_id = i_id_livre
      AND date_retour IS NULL;

    RETURN (o_date_retour_prevue IS NULL);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        o_date_retour_prevue := NULL;
        RETURN TRUE;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur inattendue dans est_disponible_fct : '||SQLERRM);
        RETURN FALSE;
END est_disponible_fct;

    PROCEDURE retourner_livre_prc(
        id_membre IN NUMBER,
        id_livre  IN NUMBER
    ) IS
        v_montant NUMBER;
    BEGIN
        UPDATE bo.emprunts
        SET date_retour = SYSDATE
        WHERE membres_id = id_membre
          AND livres_id  = id_livre
          AND date_retour IS NULL;

        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' emprunt(s) mis à jour.');

        IF est_penalites_impayees_fct(id_membre, v_montant) THEN
            DBMS_OUTPUT.PUT_LINE('Attention : pénalités de '||v_montant||' $ pour retards.');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur lors du retour du livre : '||SQLERRM);
    END retourner_livre_prc;

FUNCTION rechercher_livre_fct(
    io_id_livre IN OUT NUMBER
) RETURN t_info_livre IS
    v_info t_info_livre;
BEGIN
        SELECT l.id,
           l.titre,
           l.isbn,
           a.nom_auteur AS auteur,
           l.maison_edition,
           l.annee_publication,
           l.langage,
           s.nom AS nom_section,
           g.nom_genre AS nom_genre,
           l.prix
    INTO v_info
    FROM bo.livres   l
    JOIN bo.auteurs  a ON a.id = l.auteurs_id
    JOIN bo.sections s ON s.id = l.sections_id
    JOIN bo.genres   g ON g.id = l.genres_id
    WHERE l.id = io_id_livre;

    RETURN v_info;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        io_id_livre := 0;
        v_info.id                := 0;
        v_info.titre             := NULL;
        v_info.isbn              := NULL;
        v_info.auteur            := NULL;
        v_info.maison_edition    := NULL;
        v_info.annee_publication := NULL;
        v_info.langage           := NULL;
        v_info.nom_section       := NULL;
        v_info.nom_genre         := NULL;
        RETURN v_info;
END rechercher_livre_fct;
PROCEDURE archiver_prc(
    p_annee IN NUMBER,
    p_mois  IN NUMBER
) IS
    v_table_name VARCHAR2(50);
BEGIN
    v_table_name := 'bo.emprunts_archive_'||p_annee||LPAD(p_mois,2,'0');
    EXECUTE IMMEDIATE 'CREATE TABLE '||v_table_name||' AS SELECT * FROM bo.emprunts WHERE TO_CHAR(date_emprunt,''YYYYMM'') = '''||p_annee||LPAD(p_mois,2,'0')||'''';
    DBMS_OUTPUT.PUT_LINE('Archive '||v_table_name||' créée.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur lors de l''archivage : '||SQLERRM);
END archiver_prc;

END gestion_emprunts_pkg;