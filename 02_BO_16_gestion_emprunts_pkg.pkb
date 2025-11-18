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
    BEGIN
        v_penalites := est_penalites_impayees_fct(id_membre, v_montant);
        IF v_penalites THEN
            RAISE e_penalites_impayees;
        END IF;

        v_dispo := est_disponible_fct(id_livre);
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
        i_id_livre IN NUMBER
    ) RETURN BOOLEAN IS
        v_nb_emprunts_actifs NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_nb_emprunts_actifs
        FROM bo.emprunts
        WHERE livres_id = i_id_livre
          AND date_retour IS NULL;

        RETURN (v_nb_emprunts_actifs = 0);

    EXCEPTION
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
        id_livre IN NUMBER
    ) RETURN bo.livres%ROWTYPE IS
        v_livre bo.livres%ROWTYPE;
    BEGIN
        SELECT * INTO v_livre
        FROM bo.livres
        WHERE id = id_livre;

        RETURN v_livre;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_livre.id := 0;
        RETURN v_livre;
END rechercher_livre_fct;
PROCEDURE archiver_prc(
    p_annee IN NUMBER,
    p_mois  IN NUMBER
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Archive '||p_annee||LPAD(p_mois,2,'0')||' créée (simulation).');
END archiver_prc;

END gestion_emprunts_pkg;