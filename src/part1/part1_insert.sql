TRUNCATE TABLE xp CASCADE;
TRUNCATE TABLE p2p CASCADE;
TRUNCATE TABLE checks CASCADE;
TRUNCATE TABLE friends CASCADE;
TRUNCATE TABLE peers CASCADE;
TRUNCATE TABLE recommendations CASCADE;
TRUNCATE TABLE tasks CASCADE;
TRUNCATE TABLE timetracking CASCADE;
TRUNCATE TABLE transferredpoints CASCADE;
TRUNCATE TABLE verter CASCADE;


INSERT INTO Peers (Nickname, Birthday)
VALUES ('A_peer', '1990-01-01'),
       ('B_peer', '1991-11-01'),
       ('C_peer', '1993-03-03'),
       ('D_peer', '1994-04-04'),
       ('E_peer', '1995-05-05'),
       ('F_peer', '1996-06-06'),
       ('G_peer', '1997-07-07'),
       ('H_peer', '1998-08-08');


INSERT INTO Tasks (Title, ParentTask, MaxXP)
VALUES ('C2_SimpleBashUtils', NULL, 250),
       ('C3_s21_stringplus', 'C2_SimpleBashUtils', 500),
       ('C5_s21_decimal', 'C3_s21_stringplus', 350),
       ('C6_s21_matrix', 'C5_s21_decimal', 200),
       ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
       ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
       ('CPP1_s21_matrixplus', 'C8_3DViewer_v1.0', 300),
       ('D01_Linux', 'C2_SimpleBashUtils', 300);


INSERT INTO Checks (ID, Peer, Task, Date)
VALUES (0, 'A_peer', 'C2_SimpleBashUtils', '2021-10-30'),
       (1, 'B_peer', 'C2_SimpleBashUtils', '2021-11-01'),
       (2, 'C_peer', 'C2_SimpleBashUtils', '2021-11-03'),
       (3, 'D_peer', 'C2_SimpleBashUtils', '2021-11-04'),
       (4, 'E_peer', 'C2_SimpleBashUtils', '2021-11-05'),
       (5, 'A_peer', 'C3_s21_stringplus', '2021-11-15'),
       (6, 'B_peer', 'C3_s21_stringplus', '2021-11-15'),
       (7, 'H_peer', 'C2_SimpleBashUtils', '2021-11-15'),
       (8, 'A_peer', 'C5_s21_decimal', '2021-11-25'),
       (9, 'A_peer', 'C6_s21_matrix', '2021-11-26'),
       (10, 'A_peer', 'C7_SmartCalc_v1.0', '2021-12-01'),
       (11, 'A_peer', 'C8_3DViewer_v1.0', '2021-12-10');



INSERT INTO P2P (Check_, CheckingPeer, State, Time)
VALUES (0, 'B_peer', 'Start', '12:00'),
       (0, 'B_peer', 'Success', '12:30'),
       (1, 'C_peer', 'Start', '15:00'),
       (1, 'C_peer', 'Success', '15:30'),
       (2, 'D_peer', 'Start', '19:00'),
       (2, 'D_peer', 'Success', '19:30'),
       (3, 'A_peer', 'Start', '11:00'),
       (3, 'A_peer', 'Failure', '11:30'),
       (4, 'H_peer', 'Start', '10:00'),
       (4, 'H_peer', 'Success', '11:00'),
       (5, 'G_peer', 'Start', '20:25'),
       (5, 'G_peer', 'Success', '21:00'),
       (6, 'A_peer', 'Start', '10:10'),
       (6, 'A_peer', 'Success', '10:40'),
       (7, 'E_peer', 'Start', '12:15'),
       (7, 'E_peer', 'Success', '12:30'),
       (8, 'G_peer', 'Start', '18:00'),
       (8, 'G_peer', 'Success', '18:30'),
       (9, 'B_peer', 'Start', '15:00'),
       (9, 'B_peer', 'Success', '15:30'),
       (10, 'D_peer', 'Start', '16:00'),
       (10, 'D_peer', 'Success', '16:50'),
       (11, 'H_peer', 'Start', '10:00'),
       (11, 'H_peer', 'Success', '11:00');


INSERT INTO Verter (Check_, State, Time)
VALUES (0, 'Start', '12:31'),
       (0, 'Success', '12:35'),
       (1, 'Start', '15:31'),
       (1, 'Success', '15:35'),
       (2, 'Start', '19:31'),
       (2, 'Failure', '19:33'),
       (4, 'Start', '11:32'),
       (4, 'Success', '11:40'),
       (5, 'Start', '21:02'),
       (5, 'Success', '21:10'),

       (6, 'Start', '10:41'),
       (6, 'Success', '10:45'),
       (7, 'Start', '12:31'),
       (7, 'Success','12:33'),
       (8, 'Start', '18:31'),
       (8, 'Success','18:33'),
       (9, 'Start', '15:31'),
       (9, 'Success','15:33');


INSERT INTO TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
VALUES ('B_peer', 'A_peer', 2),
       ('A_peer', 'B_peer', 1),
       ('C_peer', 'B_peer', 1),
       ('D_peer', 'C_peer', 1),
       ('A_peer', 'D_peer', 1),
       ('H_peer', 'E_peer', 1),
       ('G_peer', 'A_peer', 2),
       ('A_peer', 'H_peer', 1),
       ('H_peer', 'A_peer', 1),
       ('E_peer', 'H_peer', 1),
       ('B_peer', 'C_peer', 1),
       ('C_peer', 'D_peer', 1),
       ('A_peer', 'G_peer', 2);


INSERT INTO Friends (Peer1, Peer2)
VALUES ('A_peer', 'G_peer'),
       ('A_peer', 'D_peer'),
       ('G_peer', 'C_peer'),
       ('F_peer', 'B_peer'),
       ('H_peer', 'E_peer');

INSERT INTO Recommendations (Peer, RecommendedPeer)
VALUES ('A_peer', 'B_peer'),
      ('B_peer', 'A_peer'),
      ('B_peer', 'C_peer'),
      ('C_peer', 'D_peer'),
      ('D_peer', 'A_peer'),
      ('E_peer', 'H_peer'),
      ('A_peer', 'G_peer'),
      ('H_peer', 'A_peer'),
      ('A_peer', 'H_peer'),
      ('H_peer', 'E_peer'),
      ('C_peer', 'B_peer'),
      ('D_peer', 'C_peer'),
      ('G_peer', 'A_peer');

INSERT INTO XP (Check_, XPAmount)
VALUES (0, 250),
       (1, 250),
       (4, 250),
       (5, 500),
       (6, 500),
       (7, 250),
       (8, 350),
       (9, 200),
       (10, 500),
       (11, 750);


INSERT INTO TimeTracking (Peer, Date, Time, State)
VALUES ('C_peer', '2022-10-09', '18:32', 1),
       ('C_peer', '2022-10-09', '19:32', 2),
       ('C_peer', '2022-10-09', '20:32', 1),
       ('C_peer', '2022-10-09', '22:32', 2),
       ('D_peer', '2022-10-09', '10:32', 1),
       ('D_peer', '2022-10-09', '12:32', 2),
       ('D_peer', '2022-10-09', '13:02', 1),
       ('D_peer', '2022-10-09', '21:32', 2),
       ('E_peer', '2022-05-09', '10:32', 1),
       ('E_peer', '2022-05-09', '12:32', 2),
       ('F_peer', '2022-06-09', '11:02', 1),
       ('F_peer', '2022-06-09', '21:32', 2),
       ('A_peer', '2022-09-21', '15:00', 1),
       ('A_peer', '2022-09-21', '22:00', 2),
       ('B_peer', '2022-09-21', '08:00', 1),
       ('B_peer', '2022-09-21', '20:00', 2),
       ('D_peer', '2022-09-21', '12:00', 1),
       ('D_peer', '2022-09-21', '19:00', 2),
       ('G_peer', '2022-09-21', '18:32', 1),
       ('B_peer', '2022-10-10', '10:32', 1),
       ('B_peer', '2022-10-10', '19:32', 1),
       ('B_peer', '2022-10-10', '22:32', 2);


