---------------------------------------
-- Zadanie 1
---------------------------------------

CREATE SCHEMA IF NOT EXISTS lab_12;
SET search_path TO lab_12;

-----------------------
-- 1. Tworzenie Tabel
-----------------------
DROP TABLE IF EXISTS dzial CASCADE;
CREATE TABLE dzial (
    dzial_nr     SERIAL PRIMARY KEY,
    nazwa        VARCHAR(32) NOT NULL,
    lokal        VARCHAR(32) NOT NULL
);

DROP TABLE IF EXISTS stopien CASCADE;
CREATE TABLE stopien (
    stopien_id          SERIAL PRIMARY KEY,
    min_wynagrodzenia   NUMERIC(10,2) NOT NULL,
    max_wynagrodzenia   NUMERIC(10,2) NOT NULL,
    CONSTRAINT check_min_wyn CHECK (min_wynagrodzenia >= 1000.0),
    CONSTRAINT check_minmax  CHECK (min_wynagrodzenia < max_wynagrodzenia)
);

DROP TABLE IF EXISTS projekt CASCADE;
CREATE TABLE projekt (
    projekt_id  SERIAL PRIMARY KEY,
    nazwa       VARCHAR(50) NOT NULL,
    start       DATE NOT NULL,
    koniec      DATE
);

DROP TABLE IF EXISTS pracownik CASCADE;
CREATE TABLE pracownik (
    pracownik_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwisko     VARCHAR(32)    NOT NULL,
    stanowisko   VARCHAR(32)    NOT NULL,
    manager_id   INTEGER,
    staz         INTEGER        NOT NULL DEFAULT 0,
    wynagrodzenie NUMERIC(10,2) NOT NULL,
    prowizja      NUMERIC(5,2),

    CONSTRAINT chk_staz      CHECK (staz >= 0),
    CONSTRAINT chk_wynagrodz CHECK (wynagrodzenie >= 1000),
    CONSTRAINT chk_prowizja  CHECK (prowizja >= 20 AND prowizja <= 60)
);

ALTER TABLE pracownik
    ADD CONSTRAINT fk_manager
    FOREIGN KEY (manager_id)
    REFERENCES pracownik (pracownik_id)
    ON DELETE SET NULL;

-- Każdy pracownik należy do jakiegoś działu (N:1)
ALTER TABLE pracownik
    ADD COLUMN dzial_id INTEGER;
ALTER TABLE pracownik
    ADD CONSTRAINT fk_dzial
    FOREIGN KEY (dzial_id)
    REFERENCES dzial(dzial_nr);


ALTER TABLE pracownik
    ADD COLUMN stopien_id INT;
ALTER TABLE pracownik
    ADD CONSTRAINT fk_stopien
    FOREIGN KEY (stopien_id)
    REFERENCES stopien(stopien_id);

-- PRACOWNIK_PROJEKT (relacja N:M)
DROP TABLE IF EXISTS pracownik_projekt CASCADE;
CREATE TABLE pracownik_projekt (
    pracownik_id INTEGER NOT NULL,
    projekt_id   INTEGER NOT NULL,
    PRIMARY KEY (pracownik_id, projekt_id),
    CONSTRAINT fk_pp_prac FOREIGN KEY (pracownik_id) REFERENCES pracownik(pracownik_id),
    CONSTRAINT fk_pp_proj FOREIGN KEY (projekt_id)   REFERENCES projekt(projekt_id)
);

---------------------------------------
-- 2. Wypełnianie przykładowymi danymi
---------------------------------------
INSERT INTO stopien (min_wynagrodzenia, max_wynagrodzenia) VALUES (1000.00, 1999.99);
INSERT INTO stopien (min_wynagrodzenia, max_wynagrodzenia) VALUES (2000.00, 2999.99);
INSERT INTO stopien (min_wynagrodzenia, max_wynagrodzenia) VALUES (3000.00, 3999.99);

INSERT INTO dzial (nazwa, lokal) VALUES
    ('Dział_Handlowy',  'Kraków'),
    ('Dział_IT',        'Warszawa'),
    ('Dział_Badawczy',  'Wrocław');

INSERT INTO projekt (nazwa, start, koniec) VALUES
    ('Projekt_A', DATE '2024-01-10', DATE '2024-06-10'),
    ('Projekt_B', DATE '2024-03-01', NULL),
    ('Projekt_C', DATE '2023-11-05', DATE '2024-01-20');

INSERT INTO pracownik (nazwisko, stanowisko, manager_id, staz, wynagrodzenie, prowizja, dzial_id, stopien_id)
  VALUES
    ('Kowalski', 'Specjalista',  NULL,  2,  1500.0,  30,  1,  1),
    ('Nowak',    'Dyrektor',     NULL, 10,  4500.0,  25,  1,  NULL),
    ('Iksiński', 'Programista',  2,    4,  2800.0,  20,  2,  2),
    ('Wójcik',   'Analityk',     2,    3,  3200.0,  50,  2,  3),
    ('Lewandowski','Researcher', 2,    5,  1800.0,  60,  3,  1);

INSERT INTO pracownik_projekt (pracownik_id, projekt_id) VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (3, 2),
    (3, 3),
    (4, 1),
    (5, 3);


---------------------------------------
-- Zadanie 2
---------------------------------------
-- 1. ilość osób zatrudnionych na poszczególnym zaszeregowaniu-zestawienie ilość_osób, stopien_zaszeregowania
SELECT s.stopien_id AS stopien_zaszeregowania,
       COUNT(p.pracownik_id) AS liczba_osob
FROM stopien s
LEFT JOIN pracownik p ON p.stopien_id = s.stopien_id
GROUP BY s.stopien_id
ORDER BY s.stopien_id;

-- tutaj z zakresem płac
SELECT s.stopien_id,
       CONCAT(s.min_wynagrodzenia, ' - ', s.max_wynagrodzenia) AS zakres_plac,
       COUNT(p.pracownik_id) AS liczba_osob
  FROM stopien s
  LEFT JOIN pracownik p ON p.stopien_id = s.stopien_id
 GROUP BY s.stopien_id, s.min_wynagrodzenia, s.max_wynagrodzenia
 ORDER BY s.stopien_id;

-- 2. dla każdego pracownika (id, nazwisko) zestawienie ilość_projektow_ukonczonych i ilość_projektow_nieukonczonych (sumarycznie)
SELECT p.pracownik_id,
       p.nazwisko,
       SUM(CASE WHEN pr.koniec IS NOT NULL THEN 1 ELSE 0 END) AS liczba_ukonczonych,
       SUM(CASE WHEN pr.koniec IS NULL THEN 1 ELSE 0 END) AS liczba_nieukonczonych
FROM pracownik p
JOIN pracownik_projekt pp ON p.pracownik_id = pp.pracownik_id
JOIN projekt pr ON pp.projekt_id = pr.projekt_id
GROUP BY p.pracownik_id, p.nazwisko
ORDER BY p.pracownik_id;

-- 3. lista pracowników (id, nazwisko), którzy byli zatrudnieni w co najmniej dwóch projektach, w których było zatrudnionych co najmniej dwóch różnych pracowników
WITH Projekty_z_wieloma AS (
  SELECT pp.projekt_id
  FROM pracownik_projekt pp
  GROUP BY pp.projekt_id
  HAVING COUNT(DISTINCT pp.pracownik_id) >= 2
)
SELECT p.pracownik_id, p.nazwisko
FROM pracownik p
JOIN pracownik_projekt pp ON p.pracownik_id = pp.pracownik_id
WHERE pp.projekt_id IN (SELECT projekt_id FROM Projekty_z_wieloma)
GROUP BY p.pracownik_id, p.nazwisko
HAVING COUNT(DISTINCT pp.projekt_id) >= 2
ORDER BY p.pracownik_id;

-- 4. projekt (nazwa), w którym było zatrudnionych najwięcej pracowników
SELECT nazwa, liczba
FROM (
  SELECT p.nazwa, COUNT(pp.pracownik_id) AS liczba
  FROM projekt p
  JOIN pracownik_projekt pp ON p.projekt_id = pp.projekt_id
  GROUP BY p.projekt_id, p.nazwa
) AS x
WHERE x.liczba = (
  SELECT MAX(x2.liczba)
  FROM (
    SELECT COUNT(pp2.pracownik_id) AS liczba
    FROM projekt p2
    JOIN pracownik_projekt pp2 ON p2.projekt_id = pp2.projekt_id
    GROUP BY p2.projekt_id
  ) AS x2
);

-- 5. dla każdego pracownika (id , nazwisko) średnia_ilość_dni  trwania  projektu, w którym pracował
SELECT p.pracownik_id,
       p.nazwisko,
       AVG(pr.koniec - pr.start) AS srednia_ilosc_dni
FROM pracownik p
JOIN pracownik_projekt pp ON p.pracownik_id = pp.pracownik_id
JOIN projekt pr ON pp.projekt_id = pr.projekt_id
WHERE pr.koniec IS NOT NULL
GROUP BY p.pracownik_id, p.nazwisko
ORDER BY p.pracownik_id;

-- gdy interesują nas nadal trwające projekty
SELECT p.pracownik_id,
       p.nazwisko,
       AVG(
         COALESCE(pr.koniec, CURRENT_DATE) - pr.start
       ) AS srednia_ilosc_dni
FROM pracownik p
JOIN pracownik_projekt pp ON p.pracownik_id = pp.pracownik_id
JOIN projekt pr ON pp.projekt_id = pr.projekt_id
GROUP BY p.pracownik_id, p.nazwisko
ORDER BY p.pracownik_id;

-- 6. lista projektów (nazwa ) i ich budżet  - suma kosztów pracowników
SELECT pr.nazwa,
       SUM(p.wynagrodzenie) AS budzet
FROM projekt pr
JOIN pracownik_projekt pp ON pr.projekt_id = pp.projekt_id
JOIN pracownik p ON pp.pracownik_id = p.pracownik_id
GROUP BY pr.projekt_id, pr.nazwa
ORDER BY pr.nazwa;

-- 7. ile projektów nieukończonych  trwa dłużej  15 dni
SELECT COUNT(*)
FROM projekt
WHERE koniec IS NULL
  AND (CURRENT_DATE - start) > 15;

-- 8. w ilu projektach brały udział osoby z poszczególnych grup zaszeregowania (stopien_zaszeregowania, ilosc_projektów)
SELECT s.stopien_id AS stopien_zaszeregowania,
       COUNT(DISTINCT pp.projekt_id) AS ilosc_projektow
FROM stopien s
JOIN pracownik p ON p.stopien_id = s.stopien_id
JOIN pracownik_projekt pp ON p.pracownik_id = pp.pracownik_id
GROUP BY s.stopien_id
ORDER BY s.stopien_id;

-- 9. nazwa projektu, który trwał najdłużej
SELECT p.nazwa, (p.koniec - p.start) AS czas_trwania
FROM projekt p
WHERE p.koniec IS NOT NULL
  AND (p.koniec - p.start) = (
       SELECT MAX(koniec - start)
       FROM projekt
       WHERE koniec IS NOT NULL
     );

-- 10. zestawienie - z wykorzystaniem kwerendy krzyżowej (CASE)
--
-- SELECT
--   'Liczba pracowników' AS etykieta,
--   SUM(CASE WHEN dzial_id = 1 THEN 1 ELSE 0 END) AS dzial_1,
--   SUM(CASE WHEN dzial_id = 2 THEN 1 ELSE 0 END) AS dzial_2,
--   SUM(CASE WHEN dzial_id = 3 THEN 1 ELSE 0 END) AS dzial_3
-- FROM pracownik;

SELECT
    d.nazwa AS nazwa_dzialu,
    SUM(CASE WHEN pr.projekt_id = 1 THEN 1 ELSE 0 END) AS projekt_1,
    SUM(CASE WHEN pr.projekt_id = 2 THEN 1 ELSE 0 END) AS projekt_2,
    SUM(CASE WHEN pr.projekt_id = 3 THEN 1 ELSE 0 END) AS projekt_3
FROM dzial d
JOIN pracownik p ON d.dzial_nr = p.dzial_id
JOIN pracownik_projekt pp ON p.pracownik_id = pp.pracownik_id
JOIN projekt pr ON pp.projekt_id = pr.projekt_id
GROUP BY d.dzial_nr, d.nazwa
ORDER BY d.dzial_nr;
