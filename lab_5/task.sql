drop schema if exists lab_5 cascade;

create schema lab_5;

SET DATESTYLE TO EUROPEAN ;

create table lab_5.czytelnik
(
	czytelnik_id		Integer			primary key,
	imie			Varchar(32)		not null,
	nazwisko		Varchar(32)		not null
);

create table lab_5.ksiazka
(
	ksiazka_id 		Integer			primary key,
	autor_imie		Varchar(32)		not null,
	autor_nazwisko	Varchar(32)		not null,
	tytul			Varchar(100)		not null,
	cena			Numeric(10,2)	 	check (cena >= 100.0),
	rok_wydania		Integer			check (rok_wydania between 1995 and 2020),
	ilosc_egzemplarzy	Integer			check (ilosc_egzemplarzy >= 0)
);

create table lab_5.kara
(
	kara_id			    Integer			primary key,
	opoznienie_min		Integer			not null,
	opoznienie_max		Integer			not null,

	check (opoznienie_min < opoznienie_max)
);

create table lab_5.wypozyczenia
(
	wypozyczenia_id     INTEGER         primary key,
	czytelnik_id        INTEGER         not null,
    	data_wypozyczenia   DATE            not null,
    	data_zwrotu         DATE            check (data_zwrotu > data_wypozyczenia OR data_zwrotu IS NULL),

    	constraint wypozyczenia_czytelnik_fk FOREIGN key (czytelnik_id) REFERENCES lab_5.czytelnik(czytelnik_id)
);

create table lab_5.wypozyczenia_ksiazka
(
	wypozyczenia_id     INTEGER         not null,
	ksiazka_id          INTEGER         not null,

    	constraint wypozyczenia_ksiazka_wypozyczenia_fk FOREIGN key (wypozyczenia_id) REFERENCES lab_5.wypozyczenia(wypozyczenia_id),
    	constraint wypozyczenia_ksiazka_ksiazka_fk FOREIGN key (ksiazka_id) REFERENCES lab_5.ksiazka(ksiazka_id),
    	primary key (wypozyczenia_id, ksiazka_id)
);

insert into lab_5.czytelnik (czytelnik_id, imie, nazwisko)
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

insert into lab_5.ksiazka (ksiazka_id, autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy)
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

insert into lab_5.kara (kara_id, opoznienie_min, opoznienie_max)
	values
	(0, 1, 6),
	(1, 7, 14),
	(2, 15, 30),
	(3, 31, 60);

insert into lab_5.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia, data_zwrotu)
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
        (20, 20, '2024-04-04', '2024-04-11');

insert into lab_5.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
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
        (20, 20);

--różnicę między najlepszym a najgorszym czytelnikiem (najlepszy to ten z największą ilością wypożyczonych różnych książek a najgorszy z najmniejszą, ale nie zerową)
SELECT
  (MAX(liczba_wypozyczonych_ksiazek) - MIN(liczba_wypozyczonych_ksiazek)) AS roznica
FROM (
  SELECT
    COUNT(DISTINCT wk.ksiazka_id) AS liczba_wypozyczonych_ksiazek
  FROM lab_5.wypozyczenia_ksiazka wk
  GROUP BY wk.wypozyczenia_id
) AS liczba_wypozyczonych_ksiazek;

--wszystkie książki pożyczane razem z tytułem XXXXX. (tytuł książki)
SELECT k.tytul
FROM lab_5.ksiazka k
JOIN lab_5.wypozyczenia_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
WHERE wk.wypozyczenia_id IN (
    SELECT wk.wypozyczenia_id
    FROM lab_5.wypozyczenia_ksiazka wk
    JOIN lab_5.ksiazka k ON wk.ksiazka_id = k.ksiazka_id
    WHERE k.tytul = 'Pan Tadeusz'
)
EXCEPT
SELECT 'Pan Tadeusz';

--wszystkich czytelników, którzy pożyczyli książki takie jak czytelnik XXXXX. (imię , nazwisko)
SELECT c.imie, c.nazwisko
FROM lab_5.czytelnik c
JOIN lab_5.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
JOIN lab_5.wypozyczenia_ksiazka wk ON w.wypozyczenia_id = wk.wypozyczenia_id
WHERE wk.ksiazka_id IN (
    SELECT wk.ksiazka_id
    FROM lab_5.wypozyczenia_ksiazka wk
    JOIN lab_5.wypozyczenia w ON wk.wypozyczenia_id = w.wypozyczenia_id
    JOIN lab_5.czytelnik c ON w.czytelnik_id = c.czytelnik_id
    WHERE c.imie = 'Jan' AND c.nazwisko = 'Kowalski'
)
EXCEPT
SELECT 'Jan' AS imie, 'Kowalski' AS nazwisko;

--książkę, która była pożyczona przez największą ilość czytelników (różnych)
SELECT k.tytul
FROM lab_5.ksiazka k
JOIN lab_5.wypozyczenia_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
GROUP BY k.tytul
HAVING COUNT(DISTINCT wk.wypozyczenia_id) = (
    SELECT MAX(reader_count)
    FROM (
        SELECT COUNT(DISTINCT wk.wypozyczenia_id) AS reader_count
        FROM lab_5.wypozyczenia_ksiazka wk
        GROUP BY wk.ksiazka_id
    ) AS subquery
);

--czytelnika, który pożyczył największą ilość książek w jednym wypożyczeniu  (imię , nazwisko, ilość)
SELECT c.imie, c.nazwisko, COUNT(wk.ksiazka_id) AS max_books
FROM lab_5.czytelnik c
JOIN lab_5.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
JOIN lab_5.wypozyczenia_ksiazka wk ON w.wypozyczenia_id = wk.wypozyczenia_id
GROUP BY c.imie, c.nazwisko
ORDER BY max_books DESC
LIMIT 1;

--procentowy udział wypożyczeń poszczególnego czytelnika we wszystkich wypożyczeniach
SELECT c.imie, c.nazwisko, COUNT(w.wypozyczenia_id) * 100.0 / (SELECT COUNT(*) FROM lab_5.wypozyczenia) AS percentage
FROM lab_5.czytelnik c
JOIN lab_5.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
GROUP BY c.imie, c.nazwisko;

--czytelników,, którzy przetrzymują książki powyżej średniej (chodzi o ilość dni ) (imię , nazwisko) -->dotyczy zakończonych wypożyczeń
SELECT c.imie, c.nazwisko
FROM lab_5.czytelnik c
JOIN lab_5.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
WHERE w.data_zwrotu IS NOT NULL AND DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) > (
    SELECT AVG(DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp))
    FROM lab_5.wypozyczenia w
    WHERE w.data_zwrotu IS NOT NULL
);


--dla każdego czytelnika, najdłuższe przetrzymanie
SELECT c.imie, c.nazwisko, (
    SELECT MAX(DATE_PART('day', w2.data_zwrotu::timestamp - w2.data_wypozyczenia::timestamp))
    FROM lab_5.wypozyczenia w2
    JOIN lab_5.czytelnik c on c.czytelnik_id = w2.czytelnik_id
    WHERE w2.czytelnik_id = c.czytelnik_id
) AS max_days
FROM lab_5.czytelnik c
JOIN lab_5.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
GROUP BY c.imie, c.nazwisko;

--czytelników, którzy nigdy nie przetrzymali książki (imię , nazwisko)
SELECT c.imie, c.nazwisko
FROM lab_5.czytelnik c
WHERE c.czytelnik_id IN (
    SELECT w.czytelnik_id
    FROM lab_5.wypozyczenia w
    WHERE w.data_zwrotu IS NOT NULL
    AND DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) < 7
);