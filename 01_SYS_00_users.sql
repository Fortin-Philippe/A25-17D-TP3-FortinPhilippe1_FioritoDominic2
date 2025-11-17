--Pour que les 'dbms_output.put_line' s'affichent
SET SERVEROUTPUT ON;

DECLARE
    TYPE t_list IS TABLE OF VARCHAR2(30);
    v_users      t_list := t_list('BO', 'TP3A_2362112', 'TP3A_2235685');
    v_passwords  t_list := t_list('bo', 'garneau', 'garneau');
    v_privileges t_list := t_list('CONNECT', 'RESOURCE', 'DBA');
    v_user_exists NUMBER;
BEGIN
    FOR i IN 1..v_users.COUNT LOOP
        SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = UPPER(v_users(i));

        IF v_user_exists > 0 THEN
            EXECUTE IMMEDIATE 'DROP USER ' || v_users(i) || ' CASCADE';
            DBMS_OUTPUT.PUT_LINE(v_users(i) || ' supprimé');
        END IF;

        EXECUTE IMMEDIATE 'CREATE USER ' || v_users(i) || ' IDENTIFIED BY ' || v_passwords(i);
        DBMS_OUTPUT.PUT_LINE(v_users(i) || ' créé');

        FOR j IN 1..v_privileges.COUNT LOOP
            EXECUTE IMMEDIATE 'GRANT ' || v_privileges(j) || ' TO ' || v_users(i);
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Tous les utilisateurs ont été créés');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLCODE || ' - ' || SQLERRM);
END;
/
