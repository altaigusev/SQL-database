-- TRUNCATE TABLE p2p CASCADE;
-- TRUNCATE TABLE checks CASCADE;
-- TRUNCATE TABLE transferredpoints CASCADE;
-- TRUNCATE TABLE verter CASCADE;

CALL proc_add_P2P (
    'A_peer',
    'B_peer',
    'C5_s21_decimal',
    'Start',
    '09:00:00'
);

CALL proc_add_P2P (
    'A_peer',
    'B_peer',
    'C5_s21_decimal',
    'Success',
    '09:20:00'
);


CALL proc_add_verter_check (
    'A_peer',
    'C5_s21_decimal',
    'Start',
    '09:21:00'
);

CALL proc_add_verter_check (
    'A_peer',
    'C5_s21_decimal',
    'Success',
    '09:22:00'
);

CALL proc_add_P2P (
    'B_peer',
    'A_peer',
    'C5_s21_decimal',
    'Start',
    '10:56:00'
);

CALL proc_add_P2P (
    'B_peer',
    'A_peer',
    'C5_s21_decimal',
    'Success',
    '10:56:00'
);

CALL proc_add_P2P (
    'C_peer',
    'A_peer',
    'C6_s21_matrix',
    'Start',
    '10:56:00'
);

CALL proc_add_P2P (
    'C_peer',
    'A_peer',
    'C6_s21_matrix',
    'Failure',
    '10:56:00'
);

INSERT INTO xp (check_, xpamount)
VALUES (12, 300);

-- INSERT INTO xp (check_, xpamount)
-- VALUES (12, 900);

-- INSERT INTO xp (check_, xpamount)
-- VALUES (7, -100);
