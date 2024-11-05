drop schema if exists lab_6 cascade;

create schema lab_6;

SET DATESTYLE TO EUROPEAN ;

create table lab_6.czytelnik
(
	czytelnik_id		Integer			primary key,
	imie			Varchar(32)		not null,
	nazwisko		Varchar(32)		not null
);

create table lab_6.ksiazka
(
	ksiazka_id 		Integer			primary key,
	autor_imie		Varchar(32)		not null,
	autor_nazwisko	Varchar(32)		not null,
	tytul			Varchar(100)		not null,
	cena			Numeric(10,2)	 	check (cena >= 100.0),
	rok_wydania		Integer			check (rok_wydania between 1995 and 2020),
	ilosc_egzemplarzy	Integer			check (ilosc_egzemplarzy >= 0)
);

create table lab_6.kara
(
	kara_id			    Integer			primary key,
	opoznienie_min		Integer			not null,
	opoznienie_max		Integer			not null,

	check (opoznienie_min < opoznienie_max)
);

create table lab_6.wypozyczenia
(
	wypozyczenia_id     INTEGER         primary key,
	czytelnik_id        INTEGER         not null,
    	data_wypozyczenia   DATE            not null,
    	data_zwrotu         DATE            check (data_zwrotu > data_wypozyczenia OR data_zwrotu IS NULL),

    	constraint wypozyczenia_czytelnik_fk FOREIGN key (czytelnik_id) REFERENCES lab_6.czytelnik(czytelnik_id)
);

create table lab_6.wypozyczenia_ksiazka
(
	wypozyczenia_id     INTEGER         not null,
	ksiazka_id          INTEGER         not null,

    	constraint wypozyczenia_ksiazka_wypozyczenia_fk FOREIGN key (wypozyczenia_id) REFERENCES lab_6.wypozyczenia(wypozyczenia_id),
    	constraint wypozyczenia_ksiazka_ksiazka_fk FOREIGN key (ksiazka_id) REFERENCES lab_6.ksiazka(ksiazka_id),
    	primary key (wypozyczenia_id, ksiazka_id)
);

insert into lab_6.czytelnik (czytelnik_id, imie, nazwisko)
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

insert into lab_6.ksiazka (ksiazka_id, autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy)
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

insert into lab_6.kara (kara_id, opoznienie_min, opoznienie_max)
	values
	(0, 1, 6),
	(1, 7, 14),
	(2, 15, 30),
	(3, 31, 60);

insert into lab_6.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia, data_zwrotu)
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

insert into lab_6.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
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



CREATE TABLE lab_6.staff ( empno INT, empname VARCHAR(20), mgrno INT ) ;

   INSERT INTO lab_6.staff VALUES ( 100, 'Kowalski',    null),
                       ( 101, 'Jasny',      100),
                       ( 102, 'Ciemny',     101),
                       ( 103, 'Szary',     102),
                       ( 104, 'Bury',    101),
                       ( 105, 'Cienki',    104),
                       ( 106, 'Dlugi', 100),
                       ( 107, 'Stary',       106),
                       ( 108, 'Mlody',   106),
                       ( 109, 'Bialy',    107),
                       ( 110, 'Sztuka',      109),
                       ( 111, 'Czarny',       110),
                       ( 112, 'Nowy',     110),
                       ( 113, 'Sredni', 110),
                       ( 114, 'Jeden',      100),
                       ( 115, 'Drugi',    114),
                       ( 116, 'Ostatni',       115),
                       ( 117, 'Lewy',   115)  ;

SELECT
    czytelnik.nazwisko AS Czytelnik,
    SUM(CASE WHEN ksiazka.tytul = 'Pan Tadeusz' THEN 1 ELSE 0 END) AS Pan_Tadeusz,
    SUM(CASE WHEN ksiazka.tytul = 'Potop' THEN 1 ELSE 0 END) AS Potop,
    SUM(CASE WHEN ksiazka.tytul = 'Lalka' THEN 1 ELSE 0 END) AS Lalka,
    SUM(CASE WHEN ksiazka.tytul = 'Nasza Szkapa' THEN 1 ELSE 0 END) AS Nasza_Szkapa,
    SUM(CASE WHEN ksiazka.tytul = 'Kordian' THEN 1 ELSE 0 END) AS Kordian,
    SUM(CASE WHEN ksiazka.tytul = 'Chłopi' THEN 1 ELSE 0 END) AS Chlopi,
    SUM(CASE WHEN ksiazka.tytul = 'Nad Niemnem' THEN 1 ELSE 0 END) AS Nad_Niemnem,
    SUM(CASE WHEN ksiazka.tytul = 'Ludzie bezdomni' THEN 1 ELSE 0 END) AS Ludzie_bezdomni,
    SUM(CASE WHEN ksiazka.tytul = 'Wesele' THEN 1 ELSE 0 END) AS Wesele,
    SUM(CASE WHEN ksiazka.tytul = 'Dziady' THEN 1 ELSE 0 END) AS Dziady,
    SUM(CASE WHEN ksiazka.tytul = 'Quo Vadis' THEN 1 ELSE 0 END) AS Quo_Vadis,
    SUM(CASE WHEN ksiazka.tytul = 'Faraon' THEN 1 ELSE 0 END) AS Faraon,
    SUM(CASE WHEN ksiazka.tytul = 'O krasnoludkach i sierotce Marysi' THEN 1 ELSE 0 END) AS O_krasnoludkach_i_sierotce_Marysi,
    SUM(CASE WHEN ksiazka.tytul = 'Balladyna' THEN 1 ELSE 0 END) AS Balladyna,
    SUM(CAse WHEN ksiazka.tytul = 'Ziemia obiecana' THEN 1 ELSE 0 END) AS Ziemia_obiecana,
    SUM(CASE WHEN ksiazka.tytul = 'Gloria victis' THEN 1 ELSE 0 END) AS Gloria_victis,
    SUM(CASE WHEN ksiazka.tytul = 'Przedwiośnie' THEN 1 ELSE 0 END) AS Przedwiośnie,
    SUM(CASE WHEN ksiazka.tytul = 'Wyzwolenie' THEN 1 ELSE 0 END) AS Wyzwolenie,
    SUM(CASE WHEN ksiazka.tytul = 'Noc Listopadowa' THEN 1 ELSE 0 END) AS Noc_listopadowa
FROM
    lab_6.czytelnik AS czytelnik
LEFT JOIN
    lab_6.wypozyczenia AS wypozyczenia ON czytelnik.czytelnik_id = wypozyczenia.czytelnik_id
LEFT JOIN
    lab_6.wypozyczenia_ksiazka AS wypozyczenia_ksiazka ON wypozyczenia.wypozyczenia_id = wypozyczenia_ksiazka.wypozyczenia_id
LEFT JOIN
    lab_6.ksiazka AS ksiazka ON wypozyczenia_ksiazka.ksiazka_id = ksiazka.ksiazka_id
GROUP BY
    czytelnik.nazwisko,
    czytelnik.czytelnik_id
Order by
    nazwisko;


