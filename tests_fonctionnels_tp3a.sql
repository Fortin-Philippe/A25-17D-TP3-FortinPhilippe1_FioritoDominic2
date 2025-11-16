set serveroutput on;


/************************************* Fait par ÉTUDIANT 1, à tester par ÉTUDIANT 2 *******************************************/
-- A. TEST FONCTIONNEL POUR est_penalites_impayees_fct
PROMPT Tests pour est_penalites_impayees_fct
DECLARE
    ID_MEMBRE NUMBER;
    v_montant NUMBER;
    v_result  BOOLEAN;
BEGIN
 
    -- LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER');
    ID_MEMBRE := 7; -- Membre 7 : Aucune amende à payer
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE, v_montant);
    DBMS_OUTPUT.PUT_LINE('Résultat : '||CASE WHEN v_result THEN 'Amendes ('||v_montant||')' ELSE 'Pas d’amendes' END);


    -- LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER');
    ID_MEMBRE := 8;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE, v_montant);
    DBMS_OUTPUT.PUT_LINE('Résultat : '||CASE WHEN v_result THEN 'Amendes ('||v_montant||')' ELSE 'Pas d’amendes' END);
    -- AFFICHER LES AMENDES TOTALES À PAYER POUR LE MEMBRE. Un paramètre de sortie doit avoir été prévu à cette fin. 

    -- LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER');
    ID_MEMBRE := 9;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE, v_montant);
    DBMS_OUTPUT.PUT_LINE('Résultat : '||CASE WHEN v_result THEN 'Amendes ('||v_montant||')' ELSE 'Pas d’amendes' END);
    -- AFFICHER LES AMENDES TOTALES À PAYER POUR LE MEMBRE. Un paramètre de sortie doit avoir été prévu à cette fin.
 

    -- LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER');
    ID_MEMBRE := 10;
    v_result := gestion_emprunts_pkg.est_penalites_impayees_fct(ID_MEMBRE, v_montant);
    DBMS_OUTPUT.PUT_LINE('Résultat : '||CASE WHEN v_result THEN 'Amendes ('||v_montant||')' ELSE 'Pas d’amendes' END);

END;
/

--B. TEST FONCTIONNEL POUR emprunter_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
    VERIF     VARCHAR2(1000); -- Pratique pour afficher les dates lors de transactions (longue concaténation des données de dates)
BEGIN
 
    -- EMPRUNT IMPOSSIBLE, CAR AMENDES
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 1 : EMPRUNT IMPOSSIBLE, CAR AMENDES');
    ID_MEMBRE := 9;
    ID_LIVRE  := 101;
    gestion_emprunts_pkg.emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);
    ROLLBACK; -- Pour annuler les modifications de la transaction (retrouver les données d'origine)
 
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
    ID_LIVRE     NUMBER;
    RETOUR_PREVU DATE;
    v_result     BOOLEAN;
BEGIN
 
    -- LIVRE DISPONIBLE POUR EMPRUNT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE DISPONIBLE POUR EMPRUNT');
    ID_LIVRE := 102;
    v_result := gestion_emprunts_pkg.est_disponible_fct(ID_LIVRE);
    DBMS_OUTPUT.PUT_LINE('Livre '||ID_LIVRE||' est disponible ? '||CASE WHEN v_result THEN 'OUI' ELSE 'NON' END);

 

    -- LIVRE DÉJÀ EMPRUNTÉ
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE DÉJÀ EMPRUNTÉ');
    ID_LIVRE := 101;
    v_result := gestion_emprunts_pkg.est_disponible_fct(ID_LIVRE);
    DBMS_OUTPUT.PUT_LINE('Livre '||ID_LIVRE||' est disponible ? '||CASE WHEN v_result THEN 'OUI' ELSE 'NON' END);
END;
/

/************************************* Fait par ÉTUDIANT 2, à tester par ÉTUDIANT 1 *******************************************/
--D. TEST FONCTIONNEL POUR retourner_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
    VERIF     VARCHAR2(1000);
BEGIN
 
    -- RETOUR SANS AMENDES À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : RETOUR SANS AMENDES À PAYER');
    ID_MEMBRE := 6; -- Membre 6 : Aucune amende à payer
    ID_LIVRE := 18; -- Livre 18 : Livre à retourner

    ROLLBACK; -- Pour annuler les modifications de la transaction (retrouver les données d'origine)



    -- RETOUR AVEC AMENDES À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : RETOUR AVEC AMENDES À PAYER');


    rollback;
END;
/

--E. TEST FONCTIONNEL POUR rechercher_livre_fct
DECLARE
    ID_LIVRE     NUMBER;
    REC_INFO_LIVRE BO.GESTION_EMPRUNTS_PKG.T_INFO_LIVRE;
BEGIN
 
    -- LIVRE EXISTANT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE EXISTANT');


 

    -- LIVRE INEXISTANT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE INEXISTANT');


END;
/




--F.  TEST FONCTIONNEL POUR archiver_prc
DECLARE
    VERIF VARCHAR2(1000);
BEGIN
 
    -- Création EMPRUNTS_ARCHIVE_202012 (valeurs par défaut)
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : Création de la table EMPRUNTS_ARCHIVE_202012 (valeurs par défaut)');

    
 
    -- Création EMPRUNTS_ARCHIVE_202104
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : Création de la table EMPRUNTS_ARCHIVE_202104 (Avril 2024)');




    --drop table EMPRUNTS_ARCHIVE_202012;
    --drop table EMPRUNTS_ARCHIVE_202104;
END;
/