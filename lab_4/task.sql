create schema lab_4;

SET DATESTYLE TO EUROPEAN ;

create table lab_4.czytelnik
(
	czytelnik_id	Integer			primary key,
	imie			Varchar(32)		not null,
	nazwisko		Varchar(32)		not null
);

create table lab_4.ksiazka
(
	ksiazka_id 			Integer			primary key,
	autor_imie			Varchar(32)		not null,
	autor_nazwisko		Varchar(32)		not null,
	tytul				Varchar(32)		not null,
	cena				Numeric(10,2) 	check (cena >= 100.0),
	rok_wydania			Integer			check (rok_wydania between 1995 and 2020),
	ilosc_egzemplarzy	Integer			check (ilosc_egzemplarzy >= 0)
);

create table lab_4.kara
(
	kara_id			Integer			primary key,
	opoznienie_min	Integer			not null,
	opoznienie_max	Integer			not null,
	check (opoznienie_min < opoznienie_max)
);

create table lab_4.wypozyczenia
(
	wypozyczenia_id     INTEGER         primary key,
    czytelnik_id        INTEGER         not null,
    data_wypozyczenia   DATE            not null,
    data_zwrotu         DATE            check (data_zwrotu > data_wypozyczenia OR data_zwrotu IS NULL),

    constraint wypozyczenia_czytelnik_fk FOREIGN key (czytelnik_id) REFERENCES lab_4.czytelnik(czytelnik_id)
);

create table lab_4.wypozyczenia_ksiazka
(
	wypozyczenia_id     INTEGER         not null,
    ksiazka_id          INTEGER         not null,

    constraint wypozyczenia_ksiazka_wypozyczenia_fk FOREIGN key (wypozyczenia_id) REFERENCES lab_4.wypozyczenia(wypozyczenia_id),
    constraint wypozyczenia_ksiazka_ksiazka_fk FOREIGN key (ksiazka_id) REFERENCES lab_4.ksiazka(ksiazka_id),
    primary key (wypozyczenia_id, ksiazka_id)
);

insert into lab_4.czytelnik (czytelnik_id, imie, nazwisko)
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
    (10, 'Agnieszka', 'Kowal');



insert into lab_4.ksiazka (ksiazka_id, autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy)
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
    (10, 'Władysław', 'Stanisław', 'Wesele', 170.00, 2012, 9);

insert into lab_4.kara (kara_id, opoznienie_min, opoznienie_max)
values
	(0, 1, 6),
    (1, 7, 14),
    (2, 15, 30),
    (3, 31, 60);

insert into lab_4.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia, data_zwrotu)
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
    (10, 10, '2024-02-15', '2024-02-22');

insert into lab_4.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
values
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10);

--ilość osób, które pożyczyły poszczególne książki  (bez podziału na oddane i nieoddane) wypisać tytuł książki  i ilość wypożyczeń
SELECT k.tytul, COUNT(wk.wypozyczenia_id) AS ilosc_wypozyczen
FROM lab_4.ksiazka k
JOIN lab_4.wypozyczenia_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
GROUP BY k.tytul;

--ilość wypożyczeń dla poszczególnego czytelnika
SELECT c.imie, c.nazwisko, COUNT(w.wypozyczenia_id) AS ilosc_wypozyczen
FROM lab_4.czytelnik c
JOIN lab_4.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
GROUP BY c.imie, c.nazwisko;

--średnie ilość dni  trwania  wypożyczenia dla zakończonych
SELECT ROUND(AVG(DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp))::numeric, 2) AS srednia_dni_trwania
FROM lab_4.wypozyczenia w
WHERE w.data_zwrotu IS NOT NULL;

--różnicę między najdłuższym a najkrótszym wypożyczeniem dla zakończonych wypozyczeń
SELECT
  (MAX(DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp)) -
   MIN(DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp))) AS roznica
FROM lab_4.wypozyczenia w
WHERE w.data_zwrotu IS NOT NULL;

--ilość wypożyczeń, które zostały przedłużone - zestawienie ilość dni , ilość wypożyczeń
SELECT DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) AS ilosc_dni, COUNT(w.wypozyczenia_id) AS ilosc_wypozyczen
FROM lab_4.wypozyczenia w
WHERE w.data_zwrotu IS NOT NULL
AND DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) > 7
GROUP BY ilosc_dni;

--książka, która była pożyczana najczęściej (zastosować LIMIT)
SELECT k.tytul, COUNT(wk.wypozyczenia_id) AS ilosc_wypozyczen
FROM lab_4.ksiazka k
JOIN lab_4.wypozyczenia_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
GROUP BY k.tytul
ORDER BY ilosc_wypozyczen DESC
LIMIT 1;

--ilość kar poszczególnych czytelników
SELECT c.imie, c.nazwisko, COUNT(k.kara_id) AS ilosc_kar
FROM lab_4.czytelnik c
JOIN lab_4.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
JOIN lab_4.kara k ON DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) BETWEEN k.opoznienie_min AND k.opoznienie_max
WHERE w.data_zwrotu IS NOT NULL
GROUP BY c.imie, c.nazwisko;


--czytelnicy, którzy  przedłużyli wypożyczenie więcej niż dwukrotnie
SELECT c.imie, c.nazwisko, COUNT(w.wypozyczenia_id) AS ilosc_przedluzen
FROM lab_4.czytelnik c
JOIN lab_4.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
WHERE w.data_zwrotu IS NOT NULL
AND DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) > 7
GROUP BY c.imie, c.nazwisko
HAVING COUNT(w.wypozyczenia_id) > 2;

--listę książek, które były pożyczone przez co najmniej dwóch różnych  czytelników
SELECT k.tytul, COUNT(DISTINCT w.czytelnik_id) AS ilosc_czytelnikow
FROM lab_4.ksiazka k
JOIN lab_4.wypozyczenia_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
JOIN lab_4.wypozyczenia w ON wk.wypozyczenia_id = w.wypozyczenia_id
GROUP BY k.tytul
HAVING COUNT(DISTINCT w.czytelnik_id) >= 2;

--zestawienie przyznanych kar - numer kary i ilość
SELECT k.kara_id, COUNT(w.wypozyczenia_id) AS ilosc_przyznanych_kar
FROM lab_4.kara k
JOIN lab_4.wypozyczenia w ON DATE_PART('day', w.data_zwrotu::timestamp - w.data_wypozyczenia::timestamp) BETWEEN k.opoznienie_min AND k.opoznienie_max
WHERE w.data_zwrotu IS NOT NULL
GROUP BY k.kara_id;
