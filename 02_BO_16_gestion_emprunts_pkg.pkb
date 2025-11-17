CREATE OR REPLACE PACKAGE BODY BO_10_gestion_emprunts_pkg IS
       -- Fonction A
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
         IF v_montant > 0 THEN
            RAISE e_penalites_impayees;
        END IF;

        RETURN (v_montant > 0);
    EXCEPTION
        WHEN e_penalites_impayees THEN
                DBMS_OUTPUT.PUT_LINE('Erreur : pénalités impayées pour membre '||i_id_membre);
            RETURN TRUE;
        WHEN OTHERS THEN
            o_montant := 0;
            RETURN FALSE;
    END est_penalites_impayees_fct;
    --Procédure B
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

        INSERT INTO bo.emprunts(livres_id, membres_id, date_emprunt)
        VALUES(id_livre, id_membre, SYSDATE);

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

        IF v_nb_emprunts_actifs > 0 THEN
            RAISE e_livre_indisponible;
        END IF;

        RETURN TRUE;

    EXCEPTION
        WHEN e_livre_indisponible THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : livre '||i_id_livre||' indisponible');
            RETURN FALSE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue dans est_disponible_fct : '||SQLERRM);
            RETURN FALSE;
    END est_disponible_fct;

    ---- procédure D

    PROCEDURE retourner_livre_prc(
        id_membre IN NUMBER,
        id_livre  IN NUMBER
    ) IS
    v_montant NUMBER;
    BEGIN
        UPDATE bo.emprunts
        SET date_retour = SYSDATE
        WHERE id_membre = id_membre
         AND id_livre  = id_livre
         AND date_retour IS NULL;

        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' date mise à jour.');

    IF est_penalites_impayees_fct(id_membre, v_montant) THEN
        DBMS_OUTPUT.PUT_LINE('ERREUR !!! : vous avez des pénalites pour une maivaise remise à la date prévus du montant de : ' || v_montant || ' $');
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Une erreur est survenue lors du retour du livre : ' || SQLERRM);
    END retourner_livre_prc;

