create schema lab_3;
create table lab_3.czytelnik
(
	czytelnik_id	Integer			primary key,
	imie			Varchar(32)		not null,
	nazwisko		Varchar(32)		not null
);

create table lab_3.ksiazka
(
	ksiazka_id 			Integer			primary key,
	autor_imie			Varchar(32)		not null,
	autor_nazwisko		Varchar(32)		not null,
	tytul				Varchar(32)		not null,
	cena				Numeric(10,2) 	check (cena >= 100.0),
	rok_wydania			Integer			check (rok_wydania between 1995 and 2020),
	ilosc_egzemplarzy	Integer			check (ilosc_egzemplarzy >= 0)
);

create table lab_3.kara
(
	kara_id			Integer			primary key,
	opoznienie_min	Integer			not null,
	opoznienie_max	Integer			not null,
	check (opoznienie_min < opoznienie_max)
);

create table lab_3.wypozyczenia
(
	wypozyczenia_id     INTEGER         primary key,
    czytelnik_id        INTEGER         not null,
    data_wypozyczenia   DATE            not null,
    data_zwrotu         DATE            check (data_zwrotu > data_wypozyczenia OR data_zwrotu IS NULL),

    constraint wypozyczenia_czytelnik_fk FOREIGN key (czytelnik_id) REFERENCES lab_3.czytelnik(czytelnik_id)
);

create table lab_3.wypozyczenia_ksiazka
(
	wypozyczenia_id     INTEGER         not null,
    ksiazka_id          INTEGER         not null,

    constraint wypozyczenia_ksiazka_wypozyczenia_fk FOREIGN key (wypozyczenia_id) REFERENCES lab_3.wypozyczenia(wypozyczenia_id),
    constraint wypozyczenia_ksiazka_ksiazka_fk FOREIGN key (ksiazka_id) REFERENCES lab_3.ksiazka(ksiazka_id),
    primary key (wypozyczenia_id, ksiazka_id)
);

insert into lab_3.czytelnik (czytelnik_id, imie, nazwisko)
values
    (1, 'Jan', 'Kowalski'),
    (2, 'Anna', 'Nowak'),
    (3, 'Tomasz', 'Zieliński'),
    (4, 'Magdalena', 'Wiśniewska');

insert into lab_3.ksiazka (ksiazka_id, autor_imie, autor_nazwisko, tytul, cena, rok_wydania, ilosc_egzemplarzy)
values
    (1, 'Adam', 'Mickiewicz', 'Pan Tadeusz', 150.00, 2000, 5),
    (2, 'Henryk', 'Sienkiewicz', 'Potop', 120.50, 1999, 3),
    (3, 'Bolesław', 'Prus', 'Lalka', 180.00, 2010, 10),
    (4, 'Maria', 'Konopnicka', 'Nasza Szkapa', 100.00, 2015, 2);

insert into lab_3.kara (kara_id, opoznienie_min, opoznienie_max)
values
	(0, 1, 6),
    (1, 7, 14),
    (2, 15, 30),
    (3, 31, 60);

insert into lab_3.wypozyczenia (wypozyczenia_id, czytelnik_id, data_wypozyczenia, data_zwrotu)
values
    (1, 1, '2024-01-01', '2024-01-08'),
    (2, 2, '2024-01-05', NULL),
    (3, 3, '2024-01-10', '2024-01-20'),
    (4, 4, '2024-01-15', NULL);

insert into lab_3.wypozyczenia_ksiazka (wypozyczenia_id, ksiazka_id)
values
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4);

select c.nazwisko, w.wypozyczenia_id
from lab_3.czytelnik c
join lab_3.wypozyczenia w ON c.czytelnik_id = w.czytelnik_id
order by c.nazwisko;

select k.tytul
from lab_3.ksiazka k
join lab_3.wypozyczenia_ksiazka wk ON k.ksiazka_id = wk.ksiazka_id
where wk.wypozyczenia_id = 1;
