TRUNCATE TABLE RESERVATIONS RESTART IDENTITY CASCADE;
TRUNCATE TABLE RESOURCES RESTART IDENTITY CASCADE;
TRUNCATE TABLE DEPARTMENT RESTART IDENTITY CASCADE;
TRUNCATE TABLE USERS RESTART IDENTITY CASCADE;

INSERT INTO DEPARTMENT (department_id, name, location, description) 
VALUES (10, 'Razvoj Softvera', 'Zgrada A, Kat 2', 'Odjel za R&D i IT podršku');

INSERT INTO DEPARTMENT (department_id, name, location, description) 
VALUES (20, 'Ljudski Potencijali', 'Zgrada A, Kat 1', 'HR, zapošljavanje i pravna pitanja');

INSERT INTO DEPARTMENT (department_id, name, location, description) 
VALUES (30, 'Marketing i Prodaja', 'Zgrada B, Kat 3', 'Odjel za odnose s javnošću i prodaju');

INSERT INTO USERS (user_id, first_name, last_name, email, phone_number, user_role, status)
VALUES (1, 'Ivan', 'Horvat', 'ivan.horvat@firma.hr', '+385911234567', 'manager', 'active');

INSERT INTO USERS (user_id, first_name, last_name, email, phone_number, user_role, status)
VALUES (2, 'Marija', 'Kovačić', 'marija.kovacic@firma.hr', '+385917654321', 'user', 'active');

INSERT INTO USERS (user_id, first_name, last_name, email, phone_number, user_role, status)
VALUES (3, 'Ana', 'Anić', 'ana.anic@firma.hr', '+38598998877', 'admin', 'active');

UPDATE DEPARTMENT SET manager_id = 1 WHERE department_id = 10;
UPDATE DEPARTMENT SET manager_id = 1 WHERE department_id = 20;

INSERT INTO RESOURCES (resource_id, department_id, name, resource_type, description, location, status, capacity)
VALUES (100, 10, 'Velika dvorana Nikola Tesla', 'room', 'Dvorana s projektorom i 20 sjedećih mjesta', 'Zgrada A, Soba 204', 'available', 20);

INSERT INTO RESOURCES (resource_id, department_id, name, resource_type, description, location, status, capacity)
VALUES (200, 20, 'Škoda Octavia (ZG-1234-XX)', 'car', 'Službeno vozilo za međugradska putovanja', 'Podzemna garaža, mjesto 15', 'available', NULL);

INSERT INTO RESOURCES (resource_id, department_id, name, resource_type, description, location, status, capacity)
VALUES (300, 30, 'Epson Mobilni Projektor v2', 'equipment', 'Prijenosni 4K projektor za prezentacije', 'Skladište opreme B', 'available', NULL);

INSERT INTO RESERVATIONS (reservation_id, user_id, resource_id, start_time, end_time, status, purpose)
VALUES (1, 2, 100, '2026-06-10 09:00:00', '2026-06-10 11:00:00', 'confirmed', 'Sprint Planning');

INSERT INTO RESERVATIONS (reservation_id, user_id, resource_id, start_time, end_time, status, purpose)
VALUES (2, 1, 200, '2026-06-12 08:00:00', '2026-06-12 16:00:00', 'confirmed', 'Put na konferenciju');