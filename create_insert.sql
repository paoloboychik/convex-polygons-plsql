DROP TABLE coords;
CREATE TABLE coords (
    x NUMBER,
    y NUMBER,
    CONSTRAINT coords_pk PRIMARY KEY (x, y)
);
INSERT ALL 
    INTO coords VALUES (-1, 1)
    INTO coords VALUES (-1, -1)
    INTO coords VALUES (2, 2)
    INTO coords VALUES (2, 4)
    INTO coords VALUES (3, -1)
(SELECT 1 FROM dual);
/*
INSERT ALL
    INTO coords VALUES (0, 0)
    INTO coords VALUES (2, 1)
(SELECT 1 FROM dual);
INSERT ALL 
    INTO coords VALUES (-4, -2)
    INTO coords VALUES (-2, -1)
    INTO coords VALUES (0, 0)
    INTO coords VALUES (2, 1)
    INTO coords VALUES (4, 2)
    INTO coords VALUES (6, 3)
(SELECT 1 FROM dual);
*/
COMMIT;
