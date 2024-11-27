-- Usunięcie schematu jeśli istnieje
DROP SCHEMA IF EXISTS drzewo_genealogiczne CASCADE;
DROP TRIGGER IF EXISTS trg_check_max_two_parents ON drzewo_genealogiczne.relacje;

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS drzewo_genealogiczne.check_max_two_parents();
DROP FUNCTION IF EXISTS drzewo_genealogiczne.czy_rodzic_dziecko(INT, INT);
DROP FUNCTION IF EXISTS drzewo_genealogiczne.czy_siblings(INT, INT);
DROP FUNCTION IF EXISTS drzewo_genealogiczne.wez_slub(INT, INT, DATE);
DROP FUNCTION IF EXISTS drzewo_genealogiczne.dodaj_potomka(
    VARCHAR(50), VARCHAR(50), drzewo_genealogiczne.plec, DATE, VARCHAR(100), INT, INT
);
DROP FUNCTION IF EXISTS drzewo_genealogiczne.przeglad_malzenstw();

-- Utworzenie schematu
CREATE SCHEMA drzewo_genealogiczne;

-- Ustawienie czasu na europejski
SET DATESTYLE TO EUROPEAN;

-- Typ płci
CREATE TYPE drzewo_genealogiczne.plec AS ENUM ('mezczyzna', 'kobieta');

-- Typ roli rodzinnej
CREATE TYPE drzewo_genealogiczne.rola AS ENUM ('matka', 'ojciec', 'córka', 'syn', 'babcia', 'dziadek',
    'wnuczka', 'wnuk', 'prababcia', 'pradziadek', 'prawnuczka', 'prawnuk');

-- Tabela osób
CREATE TABLE drzewo_genealogiczne.osoby (
    osoba_id SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    nazwisko_panienskie VARCHAR(50),
    plec drzewo_genealogiczne.plec NOT NULL,
    data_urodzenia DATE NOT NULL,
    miejsce_urodzenia VARCHAR(100),
    data_zgonu DATE
);

-- Tabela relacji rodzicielskich
CREATE TABLE drzewo_genealogiczne.relacje (
    relacja_id SERIAL PRIMARY KEY,
    osoba1_id INT NOT NULL REFERENCES drzewo_genealogiczne.osoby(osoba_id),
    osoba2_id INT NOT NULL REFERENCES drzewo_genealogiczne.osoby(osoba_id),
    rola drzewo_genealogiczne.rola NOT NULL,
    CONSTRAINT unikalna_relacja UNIQUE (osoba1_id, osoba2_id, rola)
);

-- Trigger sprawdzający, czy dziecko nie ma więcej niż dwóch rodziców
CREATE OR REPLACE FUNCTION drzewo_genealogiczne.check_max_two_parents()
RETURNS TRIGGER AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM drzewo_genealogiczne.relacje
    WHERE osoba2_id = NEW.osoba2_id AND rola IN ('matka', 'ojciec');

    IF v_count > 2 THEN
        RAISE EXCEPTION 'Dziecko o ID % ma już dwóch rodziców', NEW.osoba2_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger do sprawdzania czy dana osoba ma maksymalnie dwóch rodziców
CREATE TRIGGER trg_check_max_two_parents
AFTER INSERT ON drzewo_genealogiczne.relacje
FOR EACH ROW
WHEN (NEW.rola IN ('matka', 'ojciec'))
EXECUTE FUNCTION drzewo_genealogiczne.check_max_two_parents();

-- Tabela małżeństw
CREATE TABLE drzewo_genealogiczne.malzenstwa (
    malzenstwo_id SERIAL PRIMARY KEY,
    osoba1_id INT NOT NULL REFERENCES drzewo_genealogiczne.osoby(osoba_id),
    osoba2_id INT NOT NULL REFERENCES drzewo_genealogiczne.osoby(osoba_id),
    data_slubu DATE NOT NULL,
    data_rozwodu DATE,
    CONSTRAINT malzenstwo_unique_constraint UNIQUE (osoba1_id, osoba2_id)
);

-- Funkcja sprawdzająca, czy dwie osoby są w relacji rodzic-dziecko
CREATE OR REPLACE FUNCTION drzewo_genealogiczne.czy_rodzic_dziecko(p_osoba1_id INT, p_osoba2_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM drzewo_genealogiczne.relacje r
        WHERE r.osoba1_id = p_osoba1_id AND r.osoba2_id = p_osoba2_id AND r.rola IN ('matka', 'ojciec')
    );
END;
$$ LANGUAGE plpgsql;

-- Funkcja sprawdzająca, czy dwie osoby są rodzeństwem
CREATE OR REPLACE FUNCTION drzewo_genealogiczne.czy_siblings(p_osoba1_id INT, p_osoba2_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    rodzice1 INT[];
    rodzice2 INT[];
BEGIN
    -- Pobranie rodziców pierwszej osoby
    SELECT ARRAY(
        SELECT r.osoba1_id FROM drzewo_genealogiczne.relacje r
        WHERE r.osoba2_id = p_osoba1_id AND r.rola IN ('matka', 'ojciec')
    ) INTO rodzice1;

    -- Pobranie rodziców drugiej osoby
    SELECT ARRAY(
        SELECT r.osoba1_id FROM drzewo_genealogiczne.relacje r
        WHERE r.osoba2_id = p_osoba2_id AND r.rola IN ('matka', 'ojciec')
    ) INTO rodzice2;

    -- Jeśli którakolwiek osoba nie ma rodziców, nie mogą być rodzeństwem
    IF array_length(rodzice1,1) IS NULL OR array_length(rodzice2,1) IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Sprawdzenie, czy mają wspólnych rodziców
    IF EXISTS (
        SELECT 1 FROM unnest(rodzice1) AS r1
        INNER JOIN unnest(rodzice2) AS r2 ON r1 = r2
    ) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Funkcja pozwalająca na wzięcie ślubu z odpowiednimi ograniczeniami i zmianą nazwiska kobiety
CREATE OR REPLACE FUNCTION drzewo_genealogiczne.wez_slub(
    p_osoba1_id INT,
    p_osoba2_id INT,
    p_data_slubu DATE
)
RETURNS VOID AS $$
DECLARE
    v_osoba1_plec drzewo_genealogiczne.plec;
    v_osoba2_plec drzewo_genealogiczne.plec;
    v_male_id INT;
    v_female_id INT;
    v_male_nazwisko VARCHAR(50);
    v_female_nazwisko VARCHAR(50);
BEGIN
    -- Sprawdzenie, czy osoby są różne
    IF p_osoba1_id = p_osoba2_id THEN
        RAISE EXCEPTION 'Osoba nie może zawrzeć małżeństwa sama ze sobą';
    END IF;

    -- Pobranie płci obu osób
    SELECT plec INTO v_osoba1_plec FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_osoba1_id;
    SELECT plec INTO v_osoba2_plec FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_osoba2_id;

    -- Sprawdzenie, czy osoby istnieją
    IF v_osoba1_plec IS NULL THEN
        RAISE EXCEPTION 'Osoba o ID % nie istnieje', p_osoba1_id;
    END IF;
    IF v_osoba2_plec IS NULL THEN
        RAISE EXCEPTION 'Osoba o ID % nie istnieje', p_osoba2_id;
    END IF;

    -- Sprawdzenie, czy osoby nie są w relacji rodzic-dziecko
    IF drzewo_genealogiczne.czy_rodzic_dziecko(p_osoba1_id, p_osoba2_id) THEN
        RAISE EXCEPTION 'Osoby są w relacji rodzic-dziecko i nie mogą zawrzeć małżeństwa';
    END IF;

    -- Sprawdzenie, czy osoby nie są rodzeństwem
    IF drzewo_genealogiczne.czy_siblings(p_osoba1_id, p_osoba2_id) THEN
        RAISE EXCEPTION 'Osoby są rodzeństwem i nie mogą zawrzeć małżeństwa';
    END IF;

    -- Sprawdzenie, czy pierwsza osoba nie jest już w związku małżeńskim
    IF EXISTS (
        SELECT 1 FROM drzewo_genealogiczne.malzenstwa m
        WHERE (m.osoba1_id = p_osoba1_id OR m.osoba2_id = p_osoba1_id)
          AND (m.data_rozwodu IS NULL OR m.data_rozwodu > p_data_slubu)
    ) THEN
        RAISE EXCEPTION 'Osoba % jest już w związku małżeńskim', p_osoba1_id;
    END IF;

    -- Sprawdzenie, czy druga osoba nie jest już w związku małżeńskim
    IF EXISTS (
        SELECT 1 FROM drzewo_genealogiczne.malzenstwa m
        WHERE (m.osoba1_id = p_osoba2_id OR m.osoba2_id = p_osoba2_id)
          AND (m.data_rozwodu IS NULL OR m.data_rozwodu > p_data_slubu)
    ) THEN
        RAISE EXCEPTION 'Osoba % jest już w związku małżeńskim', p_osoba2_id;
    END IF;

    -- Wstawienie nowego małżeństwa
    INSERT INTO drzewo_genealogiczne.malzenstwa (osoba1_id, osoba2_id, data_slubu)
    VALUES (p_osoba1_id, p_osoba2_id, p_data_slubu);

    -- Zmiana nazwiska kobiety
    IF v_osoba1_plec = 'kobieta' AND v_osoba2_plec = 'mezczyzna' THEN
        v_female_id := p_osoba1_id;
        v_male_id := p_osoba2_id;
    ELSIF v_osoba1_plec = 'mezczyzna' AND v_osoba2_plec = 'kobieta' THEN
        v_female_id := p_osoba2_id;
        v_male_id := p_osoba1_id;
    ELSE
        -- W przypadku małżeństw jednopłciowych nie zmieniamy nazwisk
        RETURN;
    END IF;

    -- Pobranie nazwiska mężczyzny
    SELECT nazwisko INTO v_male_nazwisko FROM drzewo_genealogiczne.osoby WHERE osoba_id = v_male_id;

    -- Dostosowanie nazwiska kobiety do formy żeńskiej
    IF RIGHT(v_male_nazwisko, 1) = 'i' THEN
        v_female_nazwisko := LEFT(v_male_nazwisko, -1) || 'a';
    ELSE
        v_female_nazwisko := v_male_nazwisko;
    END IF;

    -- Aktualizacja nazwiska kobiety i zapisanie nazwiska panieńskiego, jeśli nie jest już ustawione
    UPDATE drzewo_genealogiczne.osoby
    SET
        nazwisko_panienskie = COALESCE(nazwisko_panienskie, nazwisko),
        nazwisko = v_female_nazwisko
    WHERE osoba_id = v_female_id;
END;
$$ LANGUAGE plpgsql;

-- Funkcja dodająca potomka z uwzględnieniem poprawek
CREATE OR REPLACE FUNCTION drzewo_genealogiczne.dodaj_potomka(
    p_imie VARCHAR(50),
    p_nazwisko VARCHAR(50),
    p_plec drzewo_genealogiczne.plec,
    p_data_urodzenia DATE,
    p_miejsce_urodzenia VARCHAR(100),
    p_rodzic1_id INT,
    p_rodzic2_id INT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_dziecko_id INT;
    v_nazwisko VARCHAR(50);
    parent_id INT;
    v_grandparents INT[];
    v_grandparent_id INT;
    v_grandparent_plec drzewo_genealogiczne.plec;
    v_great_grandparents INT[];
    v_great_grandparent_id INT;
    v_great_grandparent_plec drzewo_genealogiczne.plec;
BEGIN
    -- Sprawdzenie, czy rodzice są różni
    IF p_rodzic1_id IS NOT NULL AND p_rodzic2_id IS NOT NULL AND p_rodzic1_id = p_rodzic2_id THEN
        RAISE EXCEPTION 'Rodzice muszą być różnymi osobami';
    END IF;

    -- Ustalenie nazwiska dziecka
    IF p_rodzic1_id IS NOT NULL THEN
        -- Sprawdzenie, czy rodzic istnieje
        IF NOT EXISTS (SELECT 1 FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic1_id) THEN
            RAISE EXCEPTION 'Rodzic o ID % nie istnieje', p_rodzic1_id;
        END IF;
        -- Jeśli rodzic1 jest mężczyzną, dziecko dziedziczy jego nazwisko
        SELECT nazwisko INTO v_nazwisko FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic1_id AND plec = 'mezczyzna';
        IF v_nazwisko IS NULL THEN
            -- rodzic1 nie jest mężczyzną, więc sprawdzamy rodzic2
            IF p_rodzic2_id IS NOT NULL THEN
                IF NOT EXISTS (SELECT 1 FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic2_id) THEN
                    RAISE EXCEPTION 'Rodzic o ID % nie istnieje', p_rodzic2_id;
                END IF;
                SELECT nazwisko INTO v_nazwisko FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic2_id AND plec = 'mezczyzna';
            END IF;
        END IF;
    ELSIF p_rodzic2_id IS NOT NULL THEN
        -- Sprawdzenie, czy rodzic2 istnieje
        IF NOT EXISTS (SELECT 1 FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic2_id) THEN
            RAISE EXCEPTION 'Rodzic o ID % nie istnieje', p_rodzic2_id;
        END IF;
        -- Jeśli rodzic2 jest mężczyzną, dziecko dziedziczy jego nazwisko
        SELECT nazwisko INTO v_nazwisko FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic2_id AND plec = 'mezczyzna';
    END IF;

    IF v_nazwisko IS NULL THEN
        -- Jeśli nie znaleziono ojca, używamy podanego nazwiska lub nazwiska matki
        IF p_rodzic1_id IS NOT NULL THEN
            SELECT nazwisko INTO v_nazwisko FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic1_id;
        ELSIF p_rodzic2_id IS NOT NULL THEN
            SELECT nazwisko INTO v_nazwisko FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic2_id;
        ELSE
            v_nazwisko := p_nazwisko;
        END IF;
    END IF;

    -- Dodanie dziecka do tabeli osoby
    INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia, miejsce_urodzenia)
    VALUES (p_imie, v_nazwisko, p_plec, p_data_urodzenia, p_miejsce_urodzenia)
    RETURNING osoba_id INTO v_dziecko_id;

    -- Dodanie relacji rodzicielskich i dziecko-rodzic
    IF p_rodzic1_id IS NOT NULL THEN
        -- Ustalenie roli rodzica na podstawie płci z rzutowaniem
        INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
        VALUES (p_rodzic1_id, v_dziecko_id,
            (CASE (SELECT plec FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic1_id)
                WHEN 'mezczyzna' THEN 'ojciec'
                WHEN 'kobieta' THEN 'matka'
            END)::drzewo_genealogiczne.rola
        );
        -- Dodanie relacji dziecko-rodzic
        INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
        VALUES (v_dziecko_id, p_rodzic1_id,
            (CASE p_plec
                WHEN 'mezczyzna' THEN 'syn'
                WHEN 'kobieta' THEN 'córka'
            END)::drzewo_genealogiczne.rola
        );
    END IF;

    IF p_rodzic2_id IS NOT NULL THEN
        -- Ustalenie roli rodzica na podstawie płci z rzutowaniem
        INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
        VALUES (p_rodzic2_id, v_dziecko_id,
            (CASE (SELECT plec FROM drzewo_genealogiczne.osoby WHERE osoba_id = p_rodzic2_id)
                WHEN 'mezczyzna' THEN 'ojciec'
                WHEN 'kobieta' THEN 'matka'
            END)::drzewo_genealogiczne.rola
        );
        -- Dodanie relacji dziecko-rodzic
        INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
        VALUES (v_dziecko_id, p_rodzic2_id,
            (CASE p_plec
                WHEN 'mezczyzna' THEN 'syn'
                WHEN 'kobieta' THEN 'córka'
            END)::drzewo_genealogiczne.rola
        );
    END IF;

    -- Dodanie relacji z dziadkami
    FOREACH parent_id IN ARRAY ARRAY[p_rodzic1_id, p_rodzic2_id]
    LOOP
        IF parent_id IS NOT NULL THEN
            -- Znajdź dziadków (rodziców rodzica)
            SELECT ARRAY(
                SELECT osoba1_id FROM drzewo_genealogiczne.relacje
                WHERE osoba2_id = parent_id AND rola IN ('matka', 'ojciec')
            ) INTO v_grandparents;

            -- Dla każdego dziadka/dziadkini dodaj relacje
            FOREACH v_grandparent_id IN ARRAY v_grandparents
            LOOP
                -- Pobierz płeć dziadka/dziadkini
                SELECT plec INTO v_grandparent_plec FROM drzewo_genealogiczne.osoby WHERE osoba_id = v_grandparent_id;

                -- Dodaj relację dziadek/babcia -> wnuk/wnuczka
                INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
                VALUES (v_grandparent_id, v_dziecko_id,
                    (CASE v_grandparent_plec
                        WHEN 'mezczyzna' THEN 'dziadek'
                        WHEN 'kobieta' THEN 'babcia'
                    END)::drzewo_genealogiczne.rola
                )
                ON CONFLICT DO NOTHING;

                -- Dodaj relację wnuk/wnuczka -> dziadek/babcia
                INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
                VALUES (v_dziecko_id, v_grandparent_id,
                    (CASE p_plec
                        WHEN 'mezczyzna' THEN 'wnuk'
                        WHEN 'kobieta' THEN 'wnuczka'
                    END)::drzewo_genealogiczne.rola
                )
                ON CONFLICT DO NOTHING;

                -- Znajdź pradziadków
                SELECT ARRAY(
                    SELECT osoba1_id FROM drzewo_genealogiczne.relacje
                    WHERE osoba2_id = v_grandparent_id AND rola IN ('matka', 'ojciec')
                ) INTO v_great_grandparents;

                -- Dla każdego pradziadka/prababci dodaj relacje
                FOREACH v_great_grandparent_id IN ARRAY v_great_grandparents
                LOOP
                    -- Pobierz płeć pradziadka/prababci
                    SELECT plec INTO v_great_grandparent_plec FROM drzewo_genealogiczne.osoby WHERE osoba_id = v_great_grandparent_id;

                    -- Dodaj relację pradziadek/prababcia -> prawnuk/prawnuczka
                    INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
                    VALUES (v_great_grandparent_id, v_dziecko_id,
                        (CASE v_great_grandparent_plec
                            WHEN 'mezczyzna' THEN 'pradziadek'
                            WHEN 'kobieta' THEN 'prababcia'
                        END)::drzewo_genealogiczne.rola
                    )
                    ON CONFLICT DO NOTHING;

                    -- Dodaj relację prawnuk/prawnuczka -> pradziadek/prababcia
                    INSERT INTO drzewo_genealogiczne.relacje (osoba1_id, osoba2_id, rola)
                    VALUES (v_dziecko_id, v_great_grandparent_id,
                        (CASE p_plec
                            WHEN 'mezczyzna' THEN 'prawnuk'
                            WHEN 'kobieta' THEN 'prawnuczka'
                        END)::drzewo_genealogiczne.rola
                    )
                    ON CONFLICT DO NOTHING;
                END LOOP;
            END LOOP;
        END IF;
    END LOOP;

    RETURN v_dziecko_id;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do przeglądu istniejących małżeństw
CREATE OR REPLACE FUNCTION drzewo_genealogiczne.przeglad_malzenstw()
RETURNS TABLE(
    malzenstwo_id INT,
    imie_osoby1 VARCHAR(50),
    nazwisko_osoby1 VARCHAR(50),
    imie_osoby2 VARCHAR(50),
    nazwisko_osoby2 VARCHAR(50),
    data_slubu DATE,
    data_rozwodu DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.malzenstwo_id,
        o1.imie AS imie_osoby1,
        o1.nazwisko AS nazwisko_osoby1,
        o2.imie AS imie_osoby2,
        o2.nazwisko AS nazwisko_osoby2,
        m.data_slubu,
        m.data_rozwodu
    FROM
        drzewo_genealogiczne.malzenstwa m
    JOIN
        drzewo_genealogiczne.osoby o1 ON m.osoba1_id = o1.osoba_id
    JOIN
        drzewo_genealogiczne.osoby o2 ON m.osoba2_id = o2.osoba_id;
END;
$$ LANGUAGE plpgsql;

-- Wstawienie osób Natalia i Stanisław
INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia)
VALUES
    ('Natalia', 'Podsiadło', 'kobieta', '1922-12-01'),
    ('Stanisław', 'Sikora', 'mezczyzna', '1917-06-26');

-- Zawarcie małżeństwa między Natalią a Stanisławem
SELECT drzewo_genealogiczne.wez_slub(1, 2, '1940-06-15');

-- Sprawdzenie danych Natalii po zawarciu małżeństwa
SELECT * FROM drzewo_genealogiczne.osoby WHERE osoba_id = 1;

-- Przegląd istniejących małżeństw
SELECT * FROM drzewo_genealogiczne.przeglad_malzenstw();

--------------- Sprawdzanie, czy mozna wziąć ślub z osobą już będącą w związku małżeńskim ---------------------
-- INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia)
-- VALUES ('Jan', 'Nowak', 'mezczyzna', '1920-05-10');
--
-- SELECT osoba_id, imie, nazwisko FROM drzewo_genealogiczne.osoby WHERE imie = 'Jan' AND nazwisko = 'Nowak';
--
-- SELECT drzewo_genealogiczne.wez_slub(1, 3, '1950-08-20');
--------------------------------------------------------------------------------------------------------------

-------------- Sprawdzanie, czy można wziąć ślub po rozwodzie -------------------------------------------------
-- UPDATE drzewo_genealogiczne.malzenstwa
-- SET data_rozwodu = '1960-01-01'
-- WHERE malzenstwo_id = 1;
--
-- SELECT * FROM drzewo_genealogiczne.malzenstwa;
--
-- SELECT drzewo_genealogiczne.wez_slub(1, 3, '1965-05-20');
-- SELECT
--     m.malzenstwo_id,
--     o1.imie AS imie_osoby1,
--     o1.nazwisko AS nazwisko_osoby1,
--     o2.imie AS imie_osoby2,
--     o2.nazwisko AS nazwisko_osoby2,
--     m.data_slubu,
--     m.data_rozwodu
-- FROM
--     drzewo_genealogiczne.malzenstwa m
-- JOIN
--     drzewo_genealogiczne.osoby o1 ON m.osoba1_id = o1.osoba_id
-- JOIN
--     drzewo_genealogiczne.osoby o2 ON m.osoba2_id = o2.osoba_id;
------------------------------------------------------------------------------------------------------------

----------------- Sprawdzanie, czy można wziąć ślub ze samą sobą -------------------------------------------
-- SELECT drzewo_genealogiczne.wez_slub(1, 1, '1990-01-01');
------------------------------------------------------------------------------------------------------------

-- Dodanie córki Haliny Sikory
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Halina',
    'Sikora',
    'kobieta',
    '1951-11-25',
    NULL,
    1,  -- Natalia
    2   -- Stanisław
);

SELECT * FROM drzewo_genealogiczne.osoby;

SELECT * FROM drzewo_genealogiczne.relacje;

--------------------- Próba dodania trzeciego rodzica dla Haliny -------------------------------------------
-- -- Dodajemy nową osobę
-- INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia)
-- VALUES ('Jan', 'Kowalski', 'mezczyzna', '1920-05-10');
--
-- -- Próbujemy dodać trzeciego rodzica
-- INSERT INTO drzewo_genealogiczne.relacje (rodzic_id, dziecko_id, rola)
-- VALUES (4, 3, 'ojciec');
------------------------------------------------------------------------------------------------------------

------------------------------ Próba zawarcia związku między rodzicem a dzieckiem --------------------------
-- SELECT drzewo_genealogiczne.wez_slub(1, 3, '1970-01-01');
------------------------------------------------------------------------------------------------------------

-- Czy Natalia jest rodzicem Haliny?
SELECT drzewo_genealogiczne.czy_rodzic_dziecko(1, 3); -- Oczekiwany wynik: TRUE

-- Czy Halina jest rodzicem Natalii?
SELECT drzewo_genealogiczne.czy_rodzic_dziecko(3, 1); -- Oczekiwany wynik: FALSE

-- Czy Stanisław jest rodzicem Haliny?
SELECT drzewo_genealogiczne.czy_rodzic_dziecko(2, 3); -- Oczekiwany wynik: TRUE

-- Czy Halina jest rodzicem Stanisława?
SELECT drzewo_genealogiczne.czy_rodzic_dziecko(3, 2); -- Oczekiwany wynik: FALSE

----------------------- Sprawdzamy czy nowy potomek jest rodzeństwem -------------------------------------
-- -- Dodanie syna Jana Sikory
-- SELECT drzewo_genealogiczne.dodaj_potomka(
--     'Jan',
--     NULL,
--     'mezczyzna',
--     '1953-05-15',
--     NULL,
--     1,  -- Natalia
--     2   -- Stanisław
-- );
--
-- -- Załóżmy, że Jan otrzymał osoba_id = 4
--
-- -- Czy Halina i Jan są rodzeństwem?
-- SELECT drzewo_genealogiczne.czy_siblings(3, 4); -- Oczekiwany wynik: TRUE
--
-- -- Czy Halina i Natalia są rodzeństwem?
-- SELECT drzewo_genealogiczne.czy_siblings(3, 1); -- Oczekiwany wynik: FALSE
----------------------------------------------------------------------------------------------------------

-- Dodanie Agnieszki Wymysło i Romana Krawca
INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia)
VALUES
    ('Agnieszka', 'Wymysło', 'kobieta', '1929-08-15'),
    ('Roman', 'Krawiec', 'mezczyzna', '1927-01-02');

-- Zawarcie małżeństwa między Agnieszką a Romanem
SELECT drzewo_genealogiczne.wez_slub(4, 5, '1950-06-20');

-- Dodanie syna Wiesława Krawca
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Wiesław',
    NULL,        -- Nazwisko zostanie automatycznie ustawione na nazwisko ojca
    'mezczyzna',
    '1953-09-12',
    NULL,
    4,  -- Agnieszka
    5   -- Roman
);

------------------------------------ Dodatkowe testy ------------------------------------------------------
SELECT * FROM drzewo_genealogiczne.relacje
WHERE osoba1_id IN (4, 5, 6) OR osoba2_id IN (4, 5, 6);

SELECT * FROM drzewo_genealogiczne.przeglad_malzenstw();

SELECT drzewo_genealogiczne.czy_rodzic_dziecko(4, 6); -- Oczekiwany wynik: TRUE

SELECT drzewo_genealogiczne.czy_siblings(3, 6); -- Oczekiwany wynik: FALSE
----------------------------------------------------------------------------------------------------------

-- Zawarcie małżeństwa między Haliną a Wiesławem
SELECT drzewo_genealogiczne.wez_slub(3, 6, '1975-05-10');
SELECT * FROM drzewo_genealogiczne.przeglad_malzenstw();

-- Dodanie córki Agaty Krawiec
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Agata',
    NULL,
    'kobieta',
    '1982-06-07',
    NULL,
    3,  -- Halina
    6   -- Wiesław
);

SELECT * FROM drzewo_genealogiczne.osoby
         WHERE imie = 'Agata';

SELECT *
FROM drzewo_genealogiczne.relacje
WHERE osoba1_id =
      (SELECT osoba_id
       FROM drzewo_genealogiczne.osoby
       WHERE imie = 'Agata') OR osoba2_id =
                                (SELECT osoba_id
                                 FROM drzewo_genealogiczne.osoby
                                 WHERE imie = 'Agata');

-- Dodanie Zofii Salwierak
INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia)
VALUES
    ('Zofia', 'Salwierak', 'kobieta', '1932-11-04'),
    ('Zygmunt', 'Kumor', 'mezczyzna', '1929-05-16');

-- Zawarcie małżeństwa między Zofią a Zygmuntem
SELECT drzewo_genealogiczne.wez_slub(8, 9, '1950-08-15');

-- Dodanie córki Grażyny Kumor
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Grażyna',
    NULL,
    'kobieta',
    '1955-10-24',
    NULL,
    8,  -- Zofia
    9   -- Zygmunt
);

-- Dodanie Heleny Bijak
INSERT INTO drzewo_genealogiczne.osoby (imie, nazwisko, plec, data_urodzenia)
VALUES
    ('Helena', 'Bijak', 'kobieta', '1923-07-15'),
    ('Leon', 'Piotrowski', 'mezczyzna', '1920-09-20');

-- Zawarcie małżeństwa między Heleną a Leonem
SELECT drzewo_genealogiczne.wez_slub(11, 12, '1945-05-30');

-- Dodanie syna Marka Piotrowskiego
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Marek',
    NULL,
    'mezczyzna',
    '1949-02-24',
    NULL,
    11,  -- Helena
    12   -- Leon
);

-- Zawarcie małżeństwa między Grażyną a Markiem
SELECT drzewo_genealogiczne.wez_slub(10, 13, '1975-09-12');

-- Dodanie syna Krzysztofa Piotrowskiego
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Krzysztof',
    NULL,
    'mezczyzna',
    '1979-03-08',
    NULL,
    10,  -- Grażyna
    13   -- Marek
);

SELECT osoba_id, imie, nazwisko, nazwisko_panienskie, plec, data_urodzenia
FROM drzewo_genealogiczne.osoby
WHERE osoba_id BETWEEN 8 AND 14;

-- Zawarcie małżeństwa między Agatą a Krzysztofem
SELECT drzewo_genealogiczne.wez_slub(7, 14, '2002-09-28');

-- Dodanie syna Dawida Piotrowskiego
SELECT drzewo_genealogiczne.dodaj_potomka(
    'Dawid',
    NULL,
    'mezczyzna',
    '2003-12-09',
    NULL,
    7,  -- Agata
    14  -- Krzysztof
);

SELECT drzewo_genealogiczne.dodaj_potomka(
    'Szymon',
    NULL,
    'mezczyzna',
    '2008-11-10',
    NULL,
    7,  -- Agata
    14  -- Krzysztof
);

SELECT drzewo_genealogiczne.dodaj_potomka(
    'Anna',
    NULL,
    'kobieta',
    '2014-03-21',
    NULL,
    7,  -- Agata
    14  -- Krzysztof
);

SELECT osoba_id, imie, nazwisko, nazwisko_panienskie, plec, data_urodzenia
FROM drzewo_genealogiczne.osoby
WHERE imie = 'Dawid';

SELECT * FROM drzewo_genealogiczne.relacje
WHERE osoba1_id = 15 OR osoba2_id = 15;

-- Czy Stanisław jest pradziadkiem Dawida?
SELECT EXISTS (
    SELECT 1 FROM drzewo_genealogiczne.relacje
    WHERE osoba1_id = 2 AND osoba2_id = 15 AND rola = 'pradziadek'
) AS stanislaw_pradziadek_dawida;

SELECT * FROM drzewo_genealogiczne.relacje;

-- Proszę opracować schemat bazy danych dla drzewa genealogicznego. Baza zawiera informacje o osobach (imię, nazwisko, data urodzenia, miejsce urodzenia, dla osób nieżyjących - data zgonu), informacje o pokrewieństwie oraz informacje o małżeństwach.
-- Zapytania do bazy danych dla wybranej osoby:
--
--  informacje o niej,
SELECT * FROM drzewo_genealogiczne.osoby WHERE osoba_id =15;
--  informacje o rodzicach,
SELECT rodzice.imie, rodzice.nazwisko, r.rola
FROM drzewo_genealogiczne.relacje r
JOIN drzewo_genealogiczne.osoby rodzice ON r.osoba1_id = rodzice.osoba_id
WHERE r.osoba2_id = 15
  AND r.rola IN ('matka', 'ojciec');
-- czy posiada dzieci, jeżeli tak to podać ich imiona.
SELECT dzieci.imie
FROM drzewo_genealogiczne.relacje r
JOIN drzewo_genealogiczne.osoby dzieci ON r.osoba2_id = dzieci.osoba_id
WHERE r.osoba1_id = 7
  AND r.rola IN ('ojciec', 'matka');

------------------------------------------- Dodatkowe sprawdzenia ---------------------------------------------------
-- Informacje o dziadkach
SELECT dziadkowie.*
FROM drzewo_genealogiczne.relacje r1
JOIN drzewo_genealogiczne.relacje r2 ON r1.osoba1_id = r2.osoba2_id
JOIN drzewo_genealogiczne.osoby dziadkowie ON r2.osoba1_id = dziadkowie.osoba_id
WHERE r1.osoba2_id = 15
  AND r2.rola IN ('matka', 'ojciec');
