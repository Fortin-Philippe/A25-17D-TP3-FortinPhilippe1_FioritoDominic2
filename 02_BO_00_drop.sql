DECLARE
    TYPE t_liste IS TABLE OF VARCHAR2(128);

    v_lst_contraintes t_liste := t_liste(
        'EMPRUNTS_FK1','EMPRUNTS_FK2',
        'LIVRES_FK1','LIVRES_FK2','LIVRES_FK3',
        'CODE_UK',
        'MEMBRES_GENRE','MEMBRES_TELEPHONE','MEMBRES_CODE','MEMBRES_PAYS',
        'SECTIONS_ID',
        'EMPRUNTS_PK','LIVRES_PK','GENRES_PK','MEMBRES_PK','AUTEURS_PK','SECTIONS_PK'
    );

    v_lst_tables t_liste := t_liste('EMPRUNTS','LIVRES','GENRES','MEMBRES','AUTEURS','SECTIONS');
    v_lst_sequences t_liste := t_liste('SEQUENCE_MEMBRES');

BEGIN
    DBMS_OUTPUT.PUT_LINE('Suppression des contraintes');

    FOR i IN 1 .. v_lst_contraintes.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE BO.' ||
                CASE
                    WHEN v_lst_contraintes(i) LIKE 'EMPRUNTS%' THEN 'EMPRUNTS'
                    WHEN v_lst_contraintes(i) LIKE 'LIVRES%'   THEN 'LIVRES'
                    WHEN v_lst_contraintes(i) LIKE 'GENRES%'   THEN 'GENRES'
                    WHEN v_lst_contraintes(i) LIKE 'MEMBRES%'  THEN 'MEMBRES'
                    WHEN v_lst_contraintes(i) LIKE 'AUTEURS%'  THEN 'AUTEURS'
                    WHEN v_lst_contraintes(i) LIKE 'SECTIONS%' THEN 'SECTIONS'
                    ELSE 'MEMBRES'
                END
                || ' DROP CONSTRAINT ' || v_lst_contraintes(i);
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Suppression des tables');

    FOR i IN 1 .. v_lst_tables.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE BO.' || v_lst_tables(i) || ' CASCADE CONSTRAINTS';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;

   DBMS_OUTPUT.PUT_LINE('Suppression des séquences');

    FOR i IN 1 .. v_lst_sequences.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE BO.' || v_lst_sequences(i);
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;

DBMS_OUTPUT.PUT_LINE('BD supprimée !');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur globale lors du DROP : ' || SQLERRM);
END;