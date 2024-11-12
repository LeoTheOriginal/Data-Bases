drop schema if exists lab_7 cascade;

create schema lab_7;

SET DATESTYLE TO EUROPEAN ;

create table lab_7.czytelnik
(
	czytelnik_id		Integer			primary key,
	imie			Varchar(32)		not null,
	nazwisko		Varchar(32)		not null
);

create table lab_7.ksiazka
(
	ksiazka_id 		Integer			primary key,
	autor_imie		Varchar(32)		not null,
	autor_nazwisko	Varchar(32)		not null,
	tytul			Varchar(100)		not null,
	cena			Numeric(10,2)	 	check (cena >= 100.0),
	rok_wydania		Integer			check (rok_wydania between 1995 and 2020),
	ilosc_egzemplarzy	Integer			check (ilosc_egzemplarzy >= 0)
);

create table lab_7.kara
(
	kara_id			    Integer			primary key,
	opoznienie_min		Integer			not null,
	opoznienie_max		Integer			not null,

	check (opoznienie_min < opoznienie_max)
);

create table lab_7.wypozyczenia
(
	wypozyczenia_id     INTEGER         primary key,
	czytelnik_id        INTEGER         not null,
    	data_wypozyczenia   DATE            not null,
    	data_zwrotu         DATE            check (data_zwrotu > data_wypozyczenia OR data_zwrotu IS NULL),

    	constraint wypozyczenia_czytelnik_fk FOREIGN key (czytelnik_id) REFERENCES lab_7.czytelnik(czytelnik_id)
);

create table lab_7.wypozyczenia_ksiazka
(
	wypozyczenia_id     INTEGER         not null,
	ksiazka_id          INTEGER         not null,

    	constraint wypozyczenia_ksiazka_wypozyczenia_fk FOREIGN key (wypozyczenia_id) REFERENCES lab_7.wypozyczenia(wypozyczenia_id),
    	constraint wypozyczenia_ksiazka_ksiazka_fk FOREIGN key (ksiazka_id) REFERENCES lab_7.ksiazka(ksiazka_id),
    	primary key (wypozyczenia_id, ksiazka_id)
);

insert into lab_7.czytelnik (czytelnik_id, imie, nazwisko)
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

insert into lab_7.ksiazka (ksiazka_id, autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy)
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

insert into lab_7.kara (kara_id, opoznienie_min, opoznienie_max)
	values
	(0, 1, 6),
	(1, 7, 14),
	(2, 15, 30),
	(3, 31, 60);

insert into lab_7.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia, data_zwrotu)
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

insert into lab_7.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
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


--Zadanie pierwsze
create table lab_7.tablica_1
    (
    ksiazka_id                      integer,
    granica                         integer    not null, --graniczna ilosc wypozyczen
    pozyczenie_plus                 integer not null, -- ilu  powyzej granicznej wartosci

    CONSTRAINT                      tablica_1_pk PRIMARY KEY(ksiazka_id)
  );


--  Napisać funkcję, która wypełnia tablicę tablica_1 informacjami o wypożyczeniach.
--  Argumentem funkcji jest wartość graniczna wypożyczeń.
--  Funkcja ma zwracać ilość książek, które przekraczają graniczną ilość wypożyczeń.
--  W tablicy tablica_1 ma się pojawić wpis dotyczący takich książek

CREATE OR REPLACE FUNCTION populate_tablica_1(threshold INTEGER) RETURNS INTEGER AS $$
DECLARE
    book_count INTEGER := 0;
BEGIN
    TRUNCATE lab_7.tablica_1;

    INSERT INTO lab_7.tablica_1 (ksiazka_id, granica, pozyczenie_plus)
    SELECT
        ks.ksiazka_id,
        threshold,
        COUNT(wk.wypozyczenia_id) - threshold
    FROM
        lab_7.ksiazka ks
        JOIN lab_7.wypozyczenia_ksiazka wk ON ks.ksiazka_id = wk.ksiazka_id
    GROUP BY
        ks.ksiazka_id
    HAVING
        COUNT(wk.wypozyczenia_id) > threshold;

    SELECT COUNT(*) INTO book_count FROM lab_7.tablica_1;

    RETURN book_count;
END;
$$ LANGUAGE plpgsql;


SELECT populate_tablica_1(2);
SELECT * FROM lab_7.tablica_1;


--Zadanie drugie
create table lab_7.tablica_2
    (
    czytelnik_id                    integer,
    ilosc                          integer, --ilość niezakończonych wypozyczeń
    data                           date, --aktualna data
    wiadomosc                      text,
    CONSTRAINT                      tablica_2_pk PRIMARY KEY(czytelnik_id)
  );


-- Napisać funkcję, która wypełnia tablicę tablica_2 danymi o zbyt dużej ilości wypożyczeń.
-- Funkcja ma zwracać ilość rekordów dopisanych do tabeli.
-- Funkcja nie ma argumentu
-- W tablicy tablica_2 mają pojawić się wpisy  dotyczące wypłat dla poszczególnych pracowników.
--      a) jeżeli czytelnik ma dwa niezakończone wypożyczenia w polu wiadomość zostanie wstawiona informacja
--          -> pierwsze ostrzezenie
--      b) jeżeli czytelnik ma więcej niż dwa niezakończone wypożyczenia w polu wiadomość zostanie wstawiony komunikat
--          -> zakaz pożyczania

CREATE OR REPLACE FUNCTION populate_tablica_2() RETURNS INTEGER AS $$
DECLARE
    reader_count INTEGER := 0;
BEGIN
    TRUNCATE lab_7.tablica_2;

    INSERT INTO lab_7.tablica_2 (czytelnik_id, ilosc, data, wiadomosc)
    SELECT
        czytelnik_id,
        COUNT(*),
        CURRENT_DATE,
        CASE
            WHEN COUNT(*) = 2 THEN 'pierwsze ostrzezenie'
            WHEN COUNT(*) > 2 THEN 'zakaz pożyczania'
        END AS wiadomosc
    FROM
        lab_7.wypozyczenia
    WHERE
        data_zwrotu IS NULL
    GROUP BY
        czytelnik_id
    HAVING
        COUNT(*) >= 2;

    SELECT COUNT(*) INTO reader_count FROM lab_7.tablica_2;

    RETURN reader_count;
END;
$$ LANGUAGE plpgsql;

SELECT populate_tablica_2();
SELECT * FROM lab_7.tablica_2;


-- Zadanie trzecie
-- Proszę utworzyć funkcję rozwiązująca równanie kwadratowe

CREATE OR REPLACE FUNCTION rownanie_1(a DOUBLE PRECISION, b DOUBLE PRECISION, c DOUBLE PRECISION)
RETURNS TEXT AS $$
DECLARE
    delta DOUBLE PRECISION;
    x1 DOUBLE PRECISION;
    x2 DOUBLE PRECISION;
    real_part DOUBLE PRECISION;
    imag_part DOUBLE PRECISION;
    result TEXT;
    info_prefix TEXT := 'INFORMACJA: ';  -- Chcialem troche poeksperymentowac
BEGIN
    delta := b * b - 4 * a * c;

    RAISE NOTICE '%DELTA = %', info_prefix, delta;

    IF delta > 0 THEN
        x1 := (-b + sqrt(delta)) / (2 * a);
        x2 := (-b - sqrt(delta)) / (2 * a);

        RAISE NOTICE '%Rozwiazanie posiada dwa rzeczywiste pierwiastki', info_prefix;
        RAISE NOTICE '%x1 = %', info_prefix, x1;
        RAISE NOTICE '%x2 = %', info_prefix, x2;

        result := format('(x1 = %s ),(x2 = %s )', x1, x2);

    ELSIF delta = 0 THEN
        x1 := -b / (2 * a);

        RAISE NOTICE '%Rozwiazanie posiada jeden rzeczywisty pierwiastek', info_prefix;
        RAISE NOTICE '%x1 = %', info_prefix, x1;

        result := format('(x1 = %s )', x1);

    ELSE
        real_part := -b / (2 * a);
        imag_part := sqrt(-delta) / (2 * a);

        RAISE NOTICE '%Rozwiazanie w dziedzinie liczb zespolonych', info_prefix;
        RAISE NOTICE '%x1 = % + %si', info_prefix, real_part, imag_part;
        RAISE NOTICE '%x2 = % - %si', info_prefix, real_part, imag_part;

        result := format('(x1 = %s + %si ),(x2 = %s - %si )', real_part, imag_part, real_part, imag_part);
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


SELECT rownanie_1(1,10,1) AS equ_solve;
SELECT rownanie_1(10,5,1) AS equ_solve;

DROP FUNCTION populate_tablica_1(threshold INTEGER);
DROP FUNCTION populate_tablica_2();
DROP FUNCTION rownanie_1(a DOUBLE PRECISION, b DOUBLE PRECISION, c DOUBLE PRECISION);