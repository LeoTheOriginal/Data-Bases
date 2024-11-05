--------------------  BOLEAN --------------------

CREATE TABLE stock_availability (
   product_id INT PRIMARY KEY,
   available BOOLEAN NOT NULL
);

INSERT INTO stock_availability (product_id, available)
VALUES  (100, TRUE), (200, FALSE), (300, 't'), (400, '1'),  (500, 'y'), (600, 'yes'),   (700, 'no'),    (800, '0');

SELECT * FROM stock_availability ;

SELECT * FROM stock_availability WHERE available = 'yes';





                    ---------------------------- CHAR, VARCHAR, TEXT ----------------------------------

--                          TYP	                                                    OPIS
    -----------------------------------------------------------------------------------------------------------------
-- CHARACTER VARYING(n), VARCHAR(n)	                      |  wartości tekstowe o ograniczonej liczbie znaków
--                                                        |  kolumna tego typu ma zmienną wielkość
--                                                        |  próba wpisania dłuższego napisu kończy sie błędem
    ------------------------------------------------------------------------------------------------------------------
-- CHARACTER(n), CHAR(n)	                              |  wartości tekstowe o ograniczonej liczbie znaków
--                                                        |  kolumna tego typu ma stałą wielkość
--                                                        |  jeśli łańcuch znaków jest krótszy niż określona długość n,
--                                                        |  to wartość kolumny zostanie wypełniona spacjami.
    ------------------------------------------------------------------------------------------------------------------
-- TEXT, VARCHAR	                                      |  wartości tekstowe o nieograniczonej liczbie znaków
--                                                        |  kolumna tego typu ma zmienną wielkość

CREATE TABLE string_fixed_values(fixed_text char(5), var_text varchar(5));

-- Próba wstawienia zbyt długich wartości
INSERT INTO string_fixed_values VALUES ('abcdefg','abcdefg');


-- Wstawienie zbyt długiego tekstu, gdzie przekraczającymi znakami są spacje
INSERT INTO string_fixed_values VALUES ('abc          ', 'cde          ');

-- Wstawienie zbyt długich wartości tekstowych, ale z jawnym rzutowaniem
INSERT INTO string_fixed_values VALUES ('abcdefg'::CHAR(5), 'abcdefg'::VARCHAR(5));


SELECT * FROM string_fixed_values;




----------------------- NUMERIC ------------------------------
drop table products;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(5,2) --precyzja 5 skala 2 --> ilosc cyfr 5 po przecinku 2
);

INSERT INTO products (name, price)
VALUES ('Phone',500.215),   --zostanie zaokraglone do w dół
       ('Tablet',500.214); --zostanie zaokraglone do w dół

SELECT * FROM products;

INSERT INTO products (name, price) VALUES('Phone',123456.21);

UPDATE products SET price = 'NaN' WHERE id = 1;

SELECT * FROM products ORDER BY price DESC;




                                    ------------------- INTEGER -------------------------

--                          TYP                         ROZMIAR      MIN                  MAX
-----------------------------------------------------------------------------------------------------------------
-- SMALLINT                                           |  2 bytes   |  -32768           | +32767
-----------------------------------------------------------------------------------------------------------------
-- INTEGER                                            |  4 bytes   |  -2147483648      | +2147483647
-----------------------------------------------------------------------------------------------------------------
-- BIGINT                                             |  8 bytes   |  -9223372036854775808 | +9223372036854775807





                                    --------------------- DATE --------------------
CREATE TABLE documents (
    document_id serial PRIMARY KEY,
    header_text VARCHAR (255) NOT NULL,
    posting_date DATE NOT NULL DEFAULT CURRENT_DATE,
    delivery_date DATE
);

INSERT INTO documents (header_text) VALUES('Billing to customer XYZ');

SELECT * FROM documents;

SELECT NOW()::date; --funkcja wbudowana zwracajaca aktualny czas

SELECT TO_CHAR(NOW() :: DATE, 'dd/mm/yyyy'); --rzutowanie na tekst

SELECT TO_CHAR(NOW() :: DATE, 'Mon dd, yyyy');

INSERT INTO documents (header_text,delivery_date ) VALUES('Billing to customer ABC','2021-11-23');

SELECT header_text, delivery_date - posting_date AS diff, now() - posting_date AS time FROM documents;

CREATE TABLE person (
    person_id serial PRIMARY KEY,
    first_name VARCHAR (255),
    last_name VARCHAR (355),
    birth_date DATE NOT NULL
    );

INSERT INTO person (first_name, last_name, birth_date)
VALUES ('Shannon','Freeman','1980-01-01'),
       ('Sheila','Wells','1978-02-05'),
       ('Ethel','Webb','1975-01-01');

SELECT first_name,  last_name,  AGE(birth_date) FROM    person;

SELECT  first_name, last_name,  EXTRACT (YEAR FROM birth_date) AS YEAR,     EXTRACT (MONTH FROM birth_date) AS MONTH,   EXTRACT (DAY FROM birth_date) AS DAY FROM person;



------------------------------- WYRAŻENIA WARUNKOWE ----------------------------------------

--CASE dla każdego wiersza zwracanego w wyniku zapytania sprawdza warunek i w zależności od wyniku wypisuje komunikat podany po słowie kluczowym THEN.
--Instrukcja CASE może wystąpić również w innych fragmentach zapytania SQL. Można ją użyć w ramach kluzuli WHERE i HAVING, ale również w klauzuli GROUP BY i ORDER BY.

--                  Porównanie z wartością lub zawartością danej kolumny

SELECT a1, a2,
   CASE wartość_lub_kolumna
     WHEN wartosc_1 THEN wynik_1
     WHEN wartosc_2 THEN wynik_2
     WHEN wartosc_3 THEN wynik_3
     [ ELSE wynik_gdy_brak_na_liscie ]
   END
FROM relacja


--                  Porównanie z wyznaczoną wartością logiczną

SELECT a1, a2,
   CASE
     WHEN wyrazenie_logiczne_1 THEN wynik_1
     WHEN wyrazenie_logiczne_2 THEN wynik_2
     WHEN wyrazenie_logiczne_3 THEN wynik_3
     [ ELSE wynik_gdy_brak_na_liscie ]
   END
FROM relacja



-- A. Zyskiem określimy różnicę między ceną sprzedaży i zakupu.

SELECT description, (sell_price - cost_price) AS zysk FROM lab.item; --jaka jest różnica między ceną sprzedaży a ceną zakupu

SELECT description, CASE  WHEN sell_price - cost_price < 0 THEN 'Strata'
                          WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN  'Zysk'
                          ELSE   'Super'
                                        END
FROM lab.item;

-- B. Ile towarów przynosi zysk, ile jest super, a ile przynosi stratę

SELECT  SUM ( CASE  WHEN sell_price - cost_price < 0 THEN 1 ELSE  0  END  ) AS "Strata",
        SUM (  CASE  WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN 1 ELSE  0  END  ) AS "Zysk",
        SUM (  CASE  WHEN sell_price - cost_price > 4   THEN 1 ELSE  0  END  ) AS "Super"
FROM lab.item;

-- C. Jaki jest sumaryczny jednostkowy zysk w poszczególych "grupach zysku"

SELECT  SUM ( CASE  WHEN sell_price - cost_price < 0 THEN sell_price - cost_price ELSE  0  END  ) AS "Strata",
          SUM (  CASE  WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN sell_price - cost_price ELSE  0  END  ) AS "Zysk",
          SUM (  CASE  WHEN sell_price - cost_price > 4   THEN sell_price - cost_price ELSE  0  END  ) AS "Super"
FROM lab.item;

-- D. Jaki jest sumaryczny jednostkowy zysk w poszczególych "grupach zysku"- CASE w GROUP BY

SELECT  SUM(sell_price - cost_price), (CASE  WHEN sell_price - cost_price < 0 THEN 'Strata'
    WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4
        THEN  'Zysk'
    ELSE   'Super'
    END) AS kolumna_zysk
FROM lab.item GROUP BY CASE
    WHEN sell_price - cost_price < 0
        THEN 'Strata'
    WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4
        THEN  'Zysk'
    ELSE
        'Super' END;

-- E. Za ile sprzedano towarw w poszczeglnuych zamwieniach

SELECT orderinfo_id AS numer_zamowienia, SUM (  sell_price * quantity ) AS Sprzedaz FROM lab.orderline JOIN lab.item USING (item_id) GROUP BY orderinfo_id;

-- F. Za ile sprzedano towarów z poszczególnych "grup zysku" - kwerenda krzyżowa

SELECT SUM ( CASE WHEN sell_price - cost_price < 0 THEN sell_price * quantity ELSE  0  END) AS "Strata",
                     SUM (  CASE  WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN sell_price * quantity  ELSE  0  END  ) AS "Zysk",
                             SUM (  CASE  WHEN sell_price - cost_price > 4   THEN sell_price * quantity ELSE  0  END  ) AS "Super"
FROM lab.orderline JOIN lab.item USING (item_id);

-- G. Za ile sprzedano towarów z poszczególnych "grup zysku" w poszczególnych zamówieniach

SELECT orderinfo_id, SUM ( CASE WHEN sell_price - cost_price < 0 THEN sell_price * quantity ELSE  0  END) AS "Strata",
                     SUM (  CASE  WHEN sell_price - cost_price >= 0 AND sell_price - cost_price <= 4   THEN sell_price * quantity  ELSE  0  END  ) AS "Zysk",
                     SUM (  CASE  WHEN sell_price - cost_price > 4   THEN sell_price * quantity ELSE  0  END  ) AS "Super"
FROM lab.orderline JOIN lab.item USING (item_id) GROUP BY orderinfo_id;




------------------------------- CTE - COMMON TABLE EXPRESSIONS ---------------------------------

-- Umożliwiają pisanie bardziej zwięzłego, czytelnego, a przede wszystkim prostszego kodu.
-- Tworzone tymczasowe tabele, które są dostępne w ramach wyrażenia WITH oraz dla następującego bezpośrednio
-- po definicji zapytania.
-- Wyrażenia CTE są szczególnie przydatne w przypadku rozbudowanych zapytań, łączących wiele tabel,
-- które chcemy użyć w kolejnym kroku, wykonując na nich dodatkowe operacje.

WITH table1_CTE [( atrybuty )] AS ( definicja zapytania )   -- definicja tabeli CTE
     [ , table2_CTE, ... ]                                  -- definicje kolejnych tabel CTE
SELECT [ atrybuty ] FROM tables_CTE ;                       -- zapytanie do tabel CTE


-- np.
WITH source AS (SELECT lname, fname FROM lab.customer)
SELECT * FROM source;


-- A. Ile różnych towarów kupili poszczególni klienci - wypisać nazwisko i ilość

WITH  zestaw AS (SELECT * FROM (lab.customer c JOIN lab.orderinfo o USING (customer_id)) JOIN lab.orderline ol USING (orderinfo_id))
SELECT lname , COUNT (DISTINCT item_id) FROM zestaw GROUP BY customer_id, lname;

-- B. Ile sztuk poszczególnych towarów kupili poszczególni klienci - wypisać nazwisko, nazwę towaru i ilość

WITH  zestaw AS (SELECT * FROM (lab.customer c JOIN lab.orderinfo o USING (customer_id)) JOIN lab.orderline ol USING (orderinfo_id)),
spis AS (SELECT * FROM  zestaw JOIN item USING(item_id))
SELECT lname , description, SUM  (quantity) FROM spis GROUP BY customer_id, lname, description;

--c. Przeniesienie rekordów do innej tabeli

--przygotowujemy nowe tablice
CREATE TABLE lab.order_old
(
    orderinfo_id                    SERIAL,
    customer_id                     INTEGER NOT NULL,
    date_placed                     DATE NOT NULL,
    date_shipped                    DATE NOT NULL,
    shipping                        NUMERIC(7,2));


CREATE TABLE lab.orderinfo_1( orderinfo_1_id SERIAL Primary KEY,
                        customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
                        date_placed DATE NOT NULL,
                        date_shipped DATE,
                        shipping NUMERIC(7,2));

 --składamy zamówienia
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(3,'13-03-2000','17-03-2000', 2.99);
INSERT INTO lab.(customer_id, date_placed, date_shipped, shipping) VALUES(8,'23-06-2000','24-06-2000', 0.00);
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(15,'02-09-2000','12-09-2000', 3.99);
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(13,'03-09-2000','10-09-2000', 2.99);
INSERT INTO lab.orderinfo_1(customer_id, date_placed, date_shipped, shipping) VALUES(8,'21-07-2000','24-07-2000', 0.00);

--przenosimy zamówienia starsze od wyznaczonej daty do tabeli order_old
WITH moved_rows AS ( DELETE FROM lab.orderinfo_1 WHERE "date_placed" < '2000-06-25' RETURNING *)
INSERT INTO lab.order_old SELECT * FROM moved_rows;

-- D. Zmiana zawartości tabeli i wypisanie ze starą wartością

WITH t (item_id, nazwa,cena_kupna,nowa_cena_sprzedazy) AS (
UPDATE lab.item SET sell_price = sell_price * 1.05
RETURNING *)  --RETURNING zwraca rekordy (atrybuty) zmienione/wstawione
SELECT * FROM t join lab.item using (item_id);




------------------------------------- CTE - RECURSIVE ---------------------------------

-- Wyrażenia CTE dają możliwość stosowania rekurencji (iteracji) w ich wnętrzu. Może to zostać wykorzystane w tabelach gdzie rekordy posiadają hierarchiczną zależność (SELF JOIN)
--
-- Definicja struktury wyrażeń rekurencyjnych WITH składa się z trzech elementów:
--
-- Określenia zapytania zakotwiczającego, jest to zazwyczaj zbiór elementów stanowiących korzeń .
-- Zapytania rekursywnego – skorelowanego z wynikiem zwracanym przez zapytanie poprzednie. Odwołujemy się tu do struktury hierarchicznej. Operator UNION (UNION ALL) łączy wszystkie przebiegi w finalny zbiór wynikowy. W każdym kroku działamy tylko na zbiorze zwracanym przez krok poprzedni.
-- Niejawnego warunku zakończenia rekurencji. Jeśli zapytanie rekurencyjne, skorelowane, nie zwróci żadnego elementu, działanie CTE zostaje porzerwane.


-- Struktura rekurencyjnego wyrażenia CTE.
WITH RECURSIVE cte_name (
    CTE_definicja_zapytania    -- część nierekursywna ( zapytanie zakotwiczające )
    UNION [ALL]
    CTE_definicja_zapytania    -- cześć rekursywna ( zapytanie rekursyne,
                               -- skorelowane z wynikiem poprzedniego zapytania )
) SELECT * FROM cte_name;


-- A. Wypisanie 10 kolejnych liczb
WITH RECURSIVE
test_with(n) AS ( VALUES(1)
                  UNION
                  SELECT n+1 FROM test_with WHERE n < 10 )
SELECT * FROM test_with ORDER BY n;

--B. UNION ALL czy UNION
SET statement_timeout = '1s'; --gdy mamy UNION ALL mozemy dokladać duplikaty, czy czść rekursywna nigdy sie nie skończy
WITH RECURSIVE source AS ( SELECT 'Hello' UNION ALL SELECT 'Hello' FROM source ) SELECT * FROM source;

RESET statement_timeout; --gdy mamy UNION nie mozemy dokladać duplikatów
WITH RECURSIVE source AS ( SELECT 'Hello' UNION  SELECT 'Hello' FROM source ) SELECT * FROM source;

--C. Tworzymy tabelę z hierarchiczną zależnością rekordów
DROP TABLE department;

CREATE TABLE department (
    id INTEGER PRIMARY KEY,  -- departament ID
    parent_department INTEGER REFERENCES department, -- ID nadrzednego departamentu
    name TEXT -- nazwa departamentu
) ;

INSERT INTO department (id, parent_department, "name") VALUES
     (0, NULL, 'ROOT'),
     (1, 0, 'A'),
     (2, 1, 'B'),
     (3, 2, 'C'),
     (4, 2, 'D'),
     (5, 0, 'E'),
     (6, 4, 'F'),
     (7, 5, 'G');

-- struktura departamentow:
--
-- ROOT-+->A-+->B-+->C
--      |         |
--      |         +->D-+->F
--      +->E-+->G

-- D. Wszystkie poddepartamenty departamentu A
WITH RECURSIVE subdepartment AS
(
    -- non-recursive term
    SELECT * FROM department WHERE name = 'A'

    UNION ALL

    -- recursive term
    SELECT d.*
    FROM
        department AS d
    JOIN
        subdepartment AS sd
      ON (d.parent_department = sd.id)
)
SELECT * FROM subdepartment ORDER BY name  ;

-- E. Usunięcie gałęzi departamentów od departamentu o id=2 włącznie:
WITH RECURSIVE delete_old_department(id) AS (
SELECT id FROM department WHERE id = 2
UNION
SELECT c.id FROM delete_old_department foo, department c WHERE foo.id =  c.parent_department)
DELETE FROM department WHERE id IN (SELECT id FROM delete_old_department);

-- F. Usunięcie wszystkich poddepartamentów departamentu o id=2
WITH RECURSIVE delete_old_department(id) AS (
SELECT id FROM department WHERE parent_department = 2
UNION
SELECT c.id FROM delete_old_department foo, department c WHERE foo.id =  c.parent_department)
DELETE FROM department WHERE id IN (SELECT id FROM delete_old_department);