drop schema if exists lab_8 cascade;

create schema lab_8;

SET DATESTYLE TO EUROPEAN;

create table lab_8.czytelnik
(
	czytelnik_id		Integer			primary key,
	imie			Varchar(32)		not null,
	nazwisko		Varchar(32)		not null
);

create table lab_8.ksiazka
(
	ksiazka_id 		Integer			primary key,
	autor_imie		Varchar(32)		not null,
	autor_nazwisko	Varchar(32)		not null,
	tytul			Varchar(100)		not null,
	cena			Numeric(10,2)	 	check (cena >= 100.0),
	rok_wydania		Integer			check (rok_wydania between 1995 and 2020),
	ilosc_egzemplarzy	Integer			check (ilosc_egzemplarzy >= 0)
);

create table lab_8.kara
(
	kara_id			    Integer			primary key,
	opoznienie_min		Integer			not null,
	opoznienie_max		Integer			not null,

	check (opoznienie_min < opoznienie_max)
);

create table lab_8.wypozyczenia
(
	wypozyczenia_id     INTEGER         primary key,
	czytelnik_id        INTEGER         not null,
    	data_wypozyczenia   DATE            not null,
    	data_zwrotu         DATE            check (data_zwrotu > data_wypozyczenia OR data_zwrotu IS NULL),

    	constraint wypozyczenia_czytelnik_fk FOREIGN key (czytelnik_id) REFERENCES lab_8.czytelnik(czytelnik_id)
);

create table lab_8.wypozyczenia_ksiazka
(
	wypozyczenia_id     INTEGER         not null,
	ksiazka_id          INTEGER         not null,

    	constraint wypozyczenia_ksiazka_wypozyczenia_fk FOREIGN key (wypozyczenia_id) REFERENCES lab_8.wypozyczenia(wypozyczenia_id),
    	constraint wypozyczenia_ksiazka_ksiazka_fk FOREIGN key (ksiazka_id) REFERENCES lab_8.ksiazka(ksiazka_id),
    	primary key (wypozyczenia_id, ksiazka_id)
);

insert into lab_8.czytelnik (czytelnik_id, imie, nazwisko)
	values
	    (1, 'Jan', 'Kowalski'),
	    (2, 'Anna', 'Nowak'),
	    (3, 'Tomasz', 'Zieliński'),
	    (4, 'Magdalena', 'Wiśniewska'),
	    (5, 'Piotr', 'Kowalczyk'),
	    (6, 'Katarzyna', 'Kowal'),
	    (7, 'Michał', 'Kowal'),
	    (8, 'Karolina', 'Kowal'),
	    (9, 'Krzysztof', 'Kowal'),
	    (10, 'Agnieszka', 'Kowal'),
	    (11, 'Barbara', 'Nowicka'),
        (12, 'Paweł', 'Kowalski'),
        (13, 'Ewa', 'Wiśniewska'),
        (14, 'Marek', 'Zieliński'),
        (15, 'Dorota', 'Kowalczyk'),
        (16, 'Janusz', 'Kowal'),
        (17, 'Monika', 'Kowal'),
        (18, 'Tadeusz', 'Kowal'),
        (19, 'Zofia', 'Kowal'),
        (20, 'Wojciech', 'Kowal');

insert into lab_8.ksiazka (ksiazka_id, autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy)
	values
	    (1, 'Adam', 'Mickiewicz', 'Pan Tadeusz', 150.00, 2000, 5),
	    (2, 'Henryk', 'Sienkiewicz', 'Potop', 120.50, 1999, 3),
	    (3, 'Bolesław', 'Prus', 'Lalka', 180.00, 2010, 10),
	    (4, 'Maria', 'Konopnicka', 'Nasza Szkapa', 100.00, 2015, 2),
	    (5, 'Juliusz', 'Słowacki', 'Kordian', 130.00, 2005, 4),
	    (6, 'Władysław', 'Reymont', 'Chłopi', 110.00, 2003, 6),
	    (7, 'Eliza', 'Orzeszkowa', 'Nad Niemnem', 140.00, 2007, 8),
	    (8, 'Stefan', 'Żeromski', 'Ludzie bezdomni', 160.00, 2009, 7),
	    (9, 'Stanisław', 'Wyspiański', 'Wesele', 170.00, 2012, 9),
	    (10, 'Władysław', 'Stanisław', 'Wesele', 170.00, 2012, 9),
	    (11, 'Adam', 'Mickiewicz', 'Dziady', 150.00, 2000, 5),
        (12, 'Henryk', 'Sienkiewicz', 'Quo Vadis', 120.50, 1999, 3),
        (13, 'Bolesław', 'Prus', 'Faraon', 180.00, 2010, 10),
        (14, 'Maria', 'Konopnicka', 'O krasnoludkach i sierotce Marysi', 100.00, 2015, 2),
        (15, 'Juliusz', 'Słowacki', 'Balladyna', 130.00, 2005, 4),
        (16, 'Władysław', 'Reymont', 'Ziemia obiecana', 110.00, 2003, 6),
        (17, 'Eliza', 'Orzeszkowa', 'Gloria victis', 140.00, 2007, 8),
        (18, 'Stefan', 'Żeromski', 'Przedwiośnie', 160.00, 2009, 7),
        (19, 'Stanisław', 'Wyspiański', 'Wyzwolenie', 170.00, 2012, 9),
        (20, 'Władysław', 'Stanisław', 'Noc listopadowa', 170.00, 2012, 9);

insert into lab_8.kara (kara_id, opoznienie_min, opoznienie_max)
	values
	(0, 1, 6),
	(1, 7, 14),
	(2, 15, 30),
	(3, 31, 60);

insert into lab_8.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia, data_zwrotu)
	values
	    (1, 1, '2024-01-01', '2024-01-08'),
	    (2, 2, '2024-01-05', NULL),
	    (3, 3, '2024-01-10', '2024-01-20'),
	    (4, 4, '2024-01-15', NULL),
	    (5, 5, '2024-01-20', '2024-01-27'),
	    (6, 6, '2024-01-25', '2024-02-01'),
	    (7, 7, '2024-02-01', '2024-02-08'),
	    (8, 8, '2024-02-05', '2024-02-12'),
	    (9, 9, '2024-02-10', '2024-02-17'),
	    (10, 10, '2024-02-15', '2024-02-22'),
	    (11, 11, '2024-02-20', '2024-02-27'),
        (12, 12, '2024-02-25', '2024-03-04'),
        (13, 13, '2024-03-01', '2024-03-03'),
        (14, 14, '2024-03-05', '2024-03-12'),
        (15, 15, '2024-03-10', '2024-03-17'),
        (16, 16, '2024-03-15', '2024-03-22'),
        (17, 17, '2024-03-20', '2024-03-27'),
        (18, 18, '2024-03-25', '2024-04-01'),
        (19, 19, '2024-03-30', '2024-04-06'),
        (20, 20, '2024-04-04', '2024-04-11'),
        (21,4,'2024-01-15',NULL),
        (22,4,'2024-01-15',NULL),
        (23,2,'2024-01-15',NULL);

insert into lab_8.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
	values
	    (1, 1),
	    (1, 3),
        (1, 4),
        (1, 5),
        (1, 6),
        (1, 7),
        (1, 8),
        (1, 9),
        (1, 10),
	    (2, 2),
	    (2,3),
	    (2,4),
	    (3, 3),
	    (4, 4),
	    (5, 5),
	    (6, 6),
	    (7, 7),
	    (8, 8),
	    (9, 9),
	    (10, 10),
        (11, 11),
        (12, 12),
        (12,3),
        (13, 13),
        (14, 14),
        (15, 15),
        (16, 16),
        (17, 17),
        (18, 18),
        (19, 19),
        (20, 20),
        (21,2),
        (22,2),
        (23, 2);


create table lab_8.tablica_1
    (
    ksiazka_id                      integer,
    granica                         integer    not null, --graniczna ilosc wypozyczen
    pozyczenie_plus                 integer not null, -- ilu  powyzej granicznej wartosci

    CONSTRAINT                      tablica_1_pk PRIMARY KEY(ksiazka_id)
  );

CREATE OR REPLACE FUNCTION populate_tablica_1(threshold INTEGER) RETURNS INTEGER AS $$
DECLARE
    book_count INTEGER := 0;
BEGIN
    TRUNCATE lab_8.tablica_1;

    INSERT INTO lab_8.tablica_1 (ksiazka_id, granica, pozyczenie_plus)
    SELECT
        ks.ksiazka_id,
        threshold,
        COUNT(wk.wypozyczenia_id) - threshold
    FROM
        lab_8.ksiazka ks
        JOIN lab_8.wypozyczenia_ksiazka wk ON ks.ksiazka_id = wk.ksiazka_id
    GROUP BY
        ks.ksiazka_id
    HAVING
        COUNT(wk.wypozyczenia_id) > threshold;

    SELECT COUNT(*) INTO book_count FROM lab_8.tablica_1;

    RETURN book_count;
END;
$$ LANGUAGE plpgsql;


SELECT populate_tablica_1(2);
SELECT * FROM lab_8.tablica_1;

DROP FUNCTION populate_tablica_1(threshold INTEGER);

-- Proszę zapisać polecenia wykorzystując podzapytania, które wybiorą
--
-- Należy dopisać kwerendy pozwalające przetestować działanie tryggerów.
--
-- Zadanie 1
-- Proszę skonstruować trygger, który zrealizuje wprowadzanie danych do tabel powiązanych.
-- Tabela tablica_1 przechowuje informacje o  ilość czytelników, którzy pożyczyli książkę wiecej niż ustalona wartość.
-- Należy skonstruować wyzwalacz, który będzie uruchamiany po każdej zmianie w tabeli pozyczone_ksiazki, który będzie aktualizował tabelę tablica_1

CREATE OR REPLACE FUNCTION lab_8.update_tablica_1() RETURNS TRIGGER AS $$
DECLARE
    threshold INTEGER := 2;
    ksiazka_ids INTEGER[];
    ksiazka_id_var INTEGER;
    wypozyczenia_count INTEGER;
    pozyczenie_plus_var INTEGER;
BEGIN
    ksiazka_ids := ARRAY[]::INTEGER[];

    IF (TG_OP = 'INSERT') THEN
        ksiazka_ids := array_append(ksiazka_ids, NEW.ksiazka_id);
    ELSIF (TG_OP = 'DELETE') THEN
        ksiazka_ids := array_append(ksiazka_ids, OLD.ksiazka_id);
    ELSIF (TG_OP = 'UPDATE') THEN
        ksiazka_ids := array_append(ksiazka_ids, OLD.ksiazka_id);
        ksiazka_ids := array_append(ksiazka_ids, NEW.ksiazka_id);
    END IF;

    ksiazka_ids := ARRAY(SELECT DISTINCT unnest(ksiazka_ids));

    FOREACH ksiazka_id_var IN ARRAY ksiazka_ids LOOP
        SELECT COUNT(*) INTO wypozyczenia_count
        FROM lab_8.wypozyczenia_ksiazka
        WHERE ksiazka_id = ksiazka_id_var;

        IF wypozyczenia_count > threshold THEN
            pozyczenie_plus_var := wypozyczenia_count - threshold;
            INSERT INTO lab_8.tablica_1 (ksiazka_id, granica, pozyczenie_plus)
            VALUES (ksiazka_id_var, threshold, pozyczenie_plus_var)
            ON CONFLICT (ksiazka_id) DO UPDATE
            SET granica = EXCLUDED.granica, pozyczenie_plus = EXCLUDED.pozyczenie_plus;
        ELSE
            DELETE FROM lab_8.tablica_1 WHERE ksiazka_id = ksiazka_id_var;
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_update_tablica_1 ON lab_8.wypozyczenia_ksiazka;

CREATE TRIGGER tr_update_tablica_1
AFTER INSERT OR UPDATE OR DELETE ON lab_8.wypozyczenia_ksiazka
FOR EACH ROW
EXECUTE FUNCTION lab_8.update_tablica_1();


SELECT * FROM lab_8.tablica_1;


INSERT INTO lab_8.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia)
VALUES (24, 1, '2024-04-15');

INSERT INTO lab_8.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
VALUES (24, 3);

SELECT * FROM lab_8.tablica_1;


SELECT wypozyczenia_id FROM lab_8.wypozyczenia_ksiazka WHERE ksiazka_id = 2;

DELETE FROM lab_8.wypozyczenia_ksiazka
WHERE wypozyczenia_id = 2 AND ksiazka_id = 2;

SELECT * FROM lab_8.tablica_1;


-- Zadanie 2
-- Proszę skonstruować trygger, który po każdych 2 przedłużeniach wypożyczenia o 7 dni zwiększa mnożnik kary czytelnika   o 2% - nie może być wyższa niż 100
-- do tabeli czytelnik dodajemy kolumnę mnoznik, która przechowuje wartość procentową o jaką zwiększamy czytelnikowi karę za przetrzymywanie książek dłużej niż 7 dni
-- ALTER TABLE czytelnik ADD COLUMN mnoznik REAL DEFAULT 1 CHECK (mnoznik BETWEEN 1.0 AND 100.0); --dodajemy

ALTER TABLE lab_8.czytelnik
ADD COLUMN mnoznik REAL DEFAULT 1 CHECK (mnoznik BETWEEN 1.0 AND 100.0);

ALTER TABLE lab_8.wypozyczenia
ADD COLUMN liczba_przedluzen INTEGER DEFAULT 0;

CREATE OR REPLACE FUNCTION lab_8.update_mnoznik() RETURNS TRIGGER AS $$
DECLARE
    interval_days INTEGER;
    new_mnoznik REAL;
BEGIN
    IF OLD.data_zwrotu IS NOT NULL AND NEW.data_zwrotu IS NOT NULL THEN
        interval_days := NEW.data_zwrotu - OLD.data_zwrotu;

        -- Check if the extension is exactly 7 days
        IF interval_days = 7 THEN
            -- Increment the liczba_przedluzen counter
            NEW.liczba_przedluzen := OLD.liczba_przedluzen + 1;

            -- Every 2 extensions, increase the mnoznik by 2%
            IF NEW.liczba_przedluzen % 2 = 0 THEN
                -- Retrieve the current mnoznik for the reader
                SELECT mnoznik INTO new_mnoznik FROM lab_8.czytelnik WHERE czytelnik_id = NEW.czytelnik_id;
                -- Increase mnoznik by 2%
                new_mnoznik := new_mnoznik + 2;
                -- Ensure mnoznik does not exceed 100
                IF new_mnoznik > 100.0 THEN
                    new_mnoznik := 100.0;
                END IF;
                -- Update the mnoznik in the czytelnik table
                UPDATE lab_8.czytelnik
                SET mnoznik = new_mnoznik
                WHERE czytelnik_id = NEW.czytelnik_id;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_mnoznik
BEFORE UPDATE OF data_zwrotu ON lab_8.wypozyczenia
FOR EACH ROW
EXECUTE FUNCTION lab_8.update_mnoznik();

SELECT czytelnik_id, mnoznik FROM lab_8.czytelnik WHERE czytelnik_id = 1;

SELECT wypozyczenia_id, liczba_przedluzen, data_zwrotu FROM lab_8.wypozyczenia WHERE wypozyczenia_id = 1;

UPDATE lab_8.wypozyczenia
SET data_zwrotu = data_zwrotu + 7
WHERE wypozyczenia_id = 1;

SELECT liczba_przedluzen FROM lab_8.wypozyczenia WHERE wypozyczenia_id = 1;

UPDATE lab_8.wypozyczenia
SET data_zwrotu = data_zwrotu + 7
WHERE wypozyczenia_id = 1;

SELECT liczba_przedluzen FROM lab_8.wypozyczenia WHERE wypozyczenia_id = 1;
SELECT mnoznik FROM lab_8.czytelnik WHERE czytelnik_id = 1;

SELECT czytelnik_id, mnoznik FROM lab_8.czytelnik WHERE czytelnik_id = 1;

UPDATE lab_8.wypozyczenia
SET data_zwrotu = data_zwrotu + 7
WHERE wypozyczenia_id = 1;

UPDATE lab_8.wypozyczenia
SET data_zwrotu = data_zwrotu + 7
WHERE wypozyczenia_id = 1;

SELECT liczba_przedluzen FROM lab_8.wypozyczenia WHERE wypozyczenia_id = 1;
SELECT mnoznik FROM lab_8.czytelnik WHERE czytelnik_id = 1;






-- Zadanie 3
-- Proszę skonstruować trygger, który zapewnienia integralność danych
-- Próba usunięcia czytelnika z tabeli czytelnik
-- w przypadku, gdy ma on niezakończone wypożyczenie  nie może  zostać usunięty  - należy wygenerować stosowny komunikat
-- w przypadku, gdy wszystkie wypożyczenia zostały zakończone usuwamy go wraz z cala jego historią
