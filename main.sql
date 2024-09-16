
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
SET VERIFY OFF;
SET SERVEROUTPUT ON;
DECLARE 
    CURSOR c_coords IS SELECT x, y FROM coords ORDER BY 1, 2;
    TYPE coords_table_type IS TABLE OF coords%ROWTYPE INDEX BY PLS_INTEGER; 
    coords_table coords_table_type;
    TYPE combs_table_type IS TABLE OF VARCHAR(100) INDEX BY PLS_INTEGER;
    combs_table combs_table_type;
    res_table combs_table_type;
    temp_table combs_table_type;
    v_size PLS_INTEGER;
    v_i PLS_INTEGER;
    v_j PLS_INTEGER;
    v_fpnt PLS_INTEGER;
    v_spnt PLS_INTEGER;
    v_tpnt PLS_INTEGER;
    v_lpnt PLS_INTEGER;
    v_test PLS_INTEGER;
    v_dx NUMBER;
    v_dy NUMBER;
    v_x1 NUMBER;
    v_y1 NUMBER;
    v_x2 NUMBER;
    v_y2 NUMBER;
    v_x3 NUMBER;
    v_y3 NUMBER;
    v_x4 NUMBER;
    v_y4 NUMBER;
    v_x5 NUMBER;
    v_y5 NUMBER;
    v_bool BOOLEAN;
    v_count PLS_INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_size FROM coords;
    IF v_size < 3 THEN
        DBMS_OUTPUT.PUT_LINE('No convex polygons');
        DBMS_OUTPUT.PUT_LINE('(less than 3 points)');
    ELSE
        v_i := 0;
        FOR i IN c_coords LOOP
            v_i := v_i + 1;
            coords_table(v_i) := i;
        END LOOP;
        v_i := 0;
        <<outloop>>
        FOR i IN 1..(v_size-1) LOOP
            <<inloop>>
            FOR j IN (1+i)..v_size LOOP
                v_i := v_i + 1;
                combs_table(v_i) := TO_CHAR(i)||' '||TO_CHAR(j);
            END LOOP inloop;
        END LOOP outloop;
        v_i := 0;
        <<outloop>>
        FOR i IN 1..(v_size-2) LOOP
            IF (i = 1) THEN
                temp_table := combs_table;
            ELSE
                temp_table.DELETE;
                v_j := 0;
                <<otherloop>>
                FOR j IN 1..res_table.COUNT LOOP
                    IF REGEXP_LIKE(res_table(j), '^(\d+ ){'||TO_CHAR(i)||'}\d+$') THEN
                        v_j := v_j + 1;
                        temp_table(v_j) := res_table(j);
                    END IF;
                END LOOP otherloop;
            END IF;
            v_count := temp_table.COUNT;
            <<midloop>>
            FOR j IN 1..v_count LOOP
                <<inloop>>
                FOR k IN 1..v_size LOOP
                    IF NOT REGEXP_LIKE(temp_table(j), '(^|\D)'||TO_CHAR(k)||'(\D|$)') 
                        AND REGEXP_SUBSTR(temp_table(j), '\d+', 1, 1) < k THEN
                        v_fpnt := REGEXP_SUBSTR(temp_table(j), '\d+', 1, 1);
                        v_spnt := REGEXP_SUBSTR(temp_table(j), '\d+', 1, 2);
                        v_tpnt := REGEXP_SUBSTR(temp_table(j), '\d+', 1, i);
                        v_lpnt := REGEXP_SUBSTR(temp_table(j), '\d+', 1, i+1);
                        v_test := k;
                        v_x1 := coords_table(v_fpnt).x;
                        v_y1 := coords_table(v_fpnt).y;
                        v_x2 := coords_table(v_spnt).x;
                        v_y2 := coords_table(v_spnt).y;
                        v_x3 := coords_table(v_tpnt).x;
                        v_y3 := coords_table(v_tpnt).y;
                        v_x4 := coords_table(v_lpnt).x;
                        v_y4 := coords_table(v_lpnt).y;
                        v_x5 := coords_table(v_test).x;
                        v_y5 := coords_table(v_test).y;
                        v_bool := FALSE;
                        v_dx := v_x2 - v_x1;
                        v_dy := v_y2 - v_y1;
                        IF v_dx = 0 AND v_dy > 0 THEN v_bool := (v_x5 > v_x1);
                        ELSIF v_dx = 0 AND v_dy < 0 THEN v_bool := (v_x5 < v_x1);
                        ELSIF v_dy = 0 AND v_dx > 0 THEN v_bool := (v_y5 < v_y1);
                        ELSIF v_dy = 0 AND v_dx < 0 THEN v_bool := (v_y5 > v_y1);
                        ELSIF v_dx > 0 AND v_dy != 0 THEN v_bool := (v_y5 < (v_dy*v_x5/v_dx+v_y1-v_x1*v_dy/v_dx));
                        ELSIF v_dx < 0 AND v_dy != 0 THEN v_bool := (v_y5 > (v_dy*v_x5/v_dx+v_y1-v_x1*v_dy/v_dx));
                        END IF;
                        v_dx := v_x4 - v_x3;
                        v_dy := v_y4 - v_y3;
                        IF v_dx = 0 AND v_dy > 0 THEN v_bool := v_bool AND (v_x5 > v_x3);
                        ELSIF v_dx = 0 AND v_dy < 0 THEN v_bool := v_bool AND (v_x5 < v_x3);
                        ELSIF v_dy = 0 AND v_dx > 0 THEN v_bool := v_bool AND (v_y5 < v_y3);
                        ELSIF v_dy = 0 AND v_dx < 0 THEN v_bool := v_bool AND (v_y5 > v_y3);
                        ELSIF v_dx > 0 AND v_dy != 0 THEN v_bool := v_bool AND (v_y5 < (v_dy*v_x5/v_dx+v_y3-v_x3*v_dy/v_dx));
                        ELSIF v_dx < 0 AND v_dy != 0 THEN v_bool := v_bool AND (v_y5 > (v_dy*v_x5/v_dx+v_y3-v_x3*v_dy/v_dx));
                        END IF;
                        v_dx := v_x4 - v_x1;
                        v_dy := v_y4 - v_y1;
                        IF v_dx = 0 AND v_dy > 0 THEN v_bool := v_bool AND (v_x5 > v_x1);
                        ELSIF v_dx = 0 AND v_dy < 0 THEN v_bool := v_bool AND (v_x5 < v_x1);
                        ELSIF v_dy = 0 AND v_dx > 0 THEN v_bool := v_bool AND (v_y5 < v_y1);
                        ELSIF v_dy = 0 AND v_dx < 0 THEN v_bool := v_bool AND (v_y5 > v_y1);
                        ELSIF v_dx > 0 AND v_dy != 0 THEN v_bool := v_bool AND (v_y5 < (v_dy*v_x5/v_dx+v_y1-v_x1*v_dy/v_dx));
                        ELSIF v_dx < 0 AND v_dy != 0 THEN v_bool := v_bool AND (v_y5 > (v_dy*v_x5/v_dx+v_y1-v_x1*v_dy/v_dx));
                        END IF;
                        IF v_bool THEN
                            v_i := v_i + 1;
                            res_table(v_i) := temp_table(j)||' '||k;
                        END IF;
                    END IF;
                END LOOP inloop;
            END LOOP midloop;
        END LOOP outloop;
        IF res_table.COUNT != 0 THEN
            DBMS_OUTPUT.PUT_LINE('Convex polygons:');
            <<outloop>>
            FOR i IN 1..res_table.COUNT LOOP
                <<inloop>>
                FOR j IN 1..REGEXP_COUNT(res_table(i), '\d+') LOOP
                    v_i := REGEXP_SUBSTR(res_table(i), '\d+', 1, j);
                    IF j = 1 THEN
                        DBMS_OUTPUT.PUT('(');
                    ELSE
                        DBMS_OUTPUT.PUT(', (');
                    END IF;
                    DBMS_OUTPUT.PUT(coords_table(v_i).x||';'||coords_table(v_i).y||')');
                END LOOP inloop;
                DBMS_OUTPUT.NEW_LINE;
            END LOOP outloop;
        ELSE
            DBMS_OUTPUT.PUT_LINE('No convex polygons');
        END IF;
    END IF;
END;
