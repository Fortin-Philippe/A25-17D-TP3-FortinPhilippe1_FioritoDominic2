set serveroutput on;


/************************************* Fait par ÉTUDIANT 1, à tester par ÉTUDIANT 2 *******************************************/
-- A. TEST FONCTIONNEL POUR est_penalites_impayees_fct
DECLARE
    id_membre NUMBER;
    v_montant NUMBER;
    v_result  BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tests pour est_penalites_impayees_fct');

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER');
    id_membre := 7;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(id_membre, v_montant);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Résultat : Amendes ('||v_montant||')');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Résultat : Pas d’amendes');
    END IF;

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER');
    id_membre := 8;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(id_membre, v_montant);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Résultat : Amendes ('||v_montant||')');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Résultat : Pas d’amendes');
    END IF;

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER');
    id_membre := 9;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(id_membre, v_montant);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Résultat : Amendes ('||v_montant||')');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Résultat : Pas d’amendes');
    END IF;

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER');
    id_membre := 10;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(id_membre, v_montant);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Résultat : Amendes ('||v_montant||')');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Résultat : Pas d’amendes');
    END IF;
END;
/
/
--B. TEST FONCTIONNEL POUR emprunter_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
BEGIN
     DBMS_OUTPUT.PUT_LINE('Tests pour emprunter_livre_prc');
    -- EMPRUNT IMPOSSIBLE, CAR AMENDES
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 1 : EMPRUNT IMPOSSIBLE, CAR AMENDES');
    ID_MEMBRE := 9;
    ID_LIVRE  := 101;
    gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);
    ROLLBACK;
 
    -- LIVRE INEXISTANT
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 2 : LIVRE INEXISTANT');
    ID_MEMBRE := 6;
    ID_LIVRE  := 9999;
    gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);
    ROLLBACK;
 
    -- LIVRE EXISTANT, MAIS DÉJÀ EMPRUNTÉ
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE EXISTANT, MAIS DÉJÀ EMPRUNTÉ');
    ID_MEMBRE := 6;
    ID_LIVRE  := 101;
    gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);
    ROLLBACK;
 
    -- CAS DE TEST no. 4 : ON PEUT EMPRUNTER LE LIVRE
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : ON PEUT EMPRUNTER LE LIVRE');
    ID_MEMBRE := 6;
    ID_LIVRE  := 102;
    gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);
    ROLLBACK;
END;
/

--C. TEST FONCTIONNEL POUR est_disponible_fct
DECLARE
    id_livre NUMBER;
    v_result BOOLEAN;
    v_date_retour_prevue DATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tests pour est_disponible_fct');

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE DISPONIBLE POUR EMPRUNT');
    id_livre := 102;
    v_result := gestion_emprunts_pkg.est_disponible_fct(id_livre, v_date_retour_prevue);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Livre '||id_livre||' est disponible ? OUI');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Livre '||id_livre||' est disponible ? NON');
        DBMS_OUTPUT.PUT_LINE('Date retour prévue : '||NVL(TO_CHAR(v_date_retour_prevue,'YYYY-MM-DD'),'NULL'));
    END IF;

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE DÉJÀ EMPRUNTÉ');
    id_livre := 101;
    v_result := gestion_emprunts_pkg.est_disponible_fct(id_livre, v_date_retour_prevue);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Livre '||id_livre||' est disponible ? OUI');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Livre '||id_livre||' est disponible ? NON');
        DBMS_OUTPUT.PUT_LINE('Date retour prévue : '||NVL(TO_CHAR(v_date_retour_prevue,'YYYY-MM-DD'),'NULL'));
    END IF;
END;
/

/************************************* Fait par ÉTUDIANT 2, à tester par ÉTUDIANT 1 *******************************************/
--D. TEST FONCTIONNEL POUR retourner_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
    V_MONTANT NUMBER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Tests pour retourner_livre_prc');
    -- RETOUR SANS AMENDES À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : RETOUR SANS AMENDES À PAYER');
    ID_MEMBRE := 6; -- Membre 6 : Aucune amende à payer
    ID_LIVRE := 18; -- Livre 18 : Livre à retourner
    gestion_emprunts_pkg.retourner_livre_prc(id_membre, id_livre);
    IF gestion_emprunts_pkg.est_penalites_impayees_fct(id_membre, v_montant) THEN
        DBMS_OUTPUT.PUT_LINE('Pénalités détectées après retour: '||v_montant);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Aucune pénalité après retour.');
    END IF;
    ROLLBACK;

    -- RETOUR AVEC AMENDES À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : RETOUR AVEC AMENDES À PAYER');
        id_membre := 9;
        id_livre  := 101;
        gestion_emprunts_pkg.retourner_livre_prc(id_membre, id_livre);
        IF gestion_emprunts_pkg.est_penalites_impayees_fct(id_membre, v_montant) THEN
            DBMS_OUTPUT.PUT_LINE('Pénalités détectées après retour: '||v_montant);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Aucune pénalité après retour.');
        END IF;
        ROLLBACK;
END;
/

--E. TEST FONCTIONNEL POUR rechercher_livre_fct
DECLARE
    ID_LIVRE     NUMBER;
    REC_INFO_LIVRE BO.GESTION_EMPRUNTS_PKG.T_INFO_LIVRE;
BEGIN
     DBMS_OUTPUT.PUT_LINE('Tests pour rechercher_livre_fct');
    -- LIVRE EXISTANT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE EXISTANT');
     id_livre := 18;
        rec_info_livre := gestion_emprunts_pkg.rechercher_livre_fct(id_livre);
        DBMS_OUTPUT.PUT_LINE(
            'Titre: '||NVL(rec_info_livre.titre,'NULL')||
            ' | ISBN: '||NVL(rec_info_livre.isbn,'NULL')||
            ' | Langage: '||NVL(rec_info_livre.langage,'NULL')||
            ' | Prix: '||TO_CHAR(rec_info_livre.prix)
        );
    -- LIVRE INEXISTANT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE INEXISTANT');
     id_livre := 9999;
        rec_info_livre := gestion_emprunts_pkg.rechercher_livre_fct(id_livre);
        DBMS_OUTPUT.PUT_LINE(
            'Titre: '||NVL(rec_info_livre.titre,'NULL')||
            ' | ISBN: '||NVL(rec_info_livre.isbn,'NULL')
        );

END;
/

--F.  TEST FONCTIONNEL POUR archiver_prc
BEGIN
 DBMS_OUTPUT.PUT_LINE('Tests pour archiver_prc');
    -- Création EMPRUNTS_ARCHIVE_202012 (valeurs par défaut)
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : Création de la table EMPRUNTS_ARCHIVE_202012 (valeurs par défaut)');
    gestion_emprunts_pkg.archiver_prc();
    
 
    -- Création EMPRUNTS_ARCHIVE_202104
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : Création de la table EMPRUNTS_ARCHIVE_202104 (Avril 2024)');
    gestion_emprunts_pkg.archiver_prc(2024, 4);
    --drop table EMPRUNTS_ARCHIVE_202012;
    --drop table EMPRUNTS_ARCHIVE_202104;
END;
/