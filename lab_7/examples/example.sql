
-- Funkcje Składowane w PostgreSQL --

-- Wprowadzenie --
-- W PostgreSQL można tworzyć własne funkcje, które realizują określone zadania. Można to robić przy użyciu SQL, PL/pgSQL
-- lub innych języków proceduralnych (jak Python, Perl, C). Dzięki funkcjom składowanym możemy rozszerzać funkcjonalność bazy,
-- budując np. logikę biznesową bezpośrednio w bazie danych.

-- Tworzenie i Usuwanie Funkcji --

-- Tworzenie funkcji --
-- Aby stworzyć funkcję, używamy składni CREATE FUNCTION. Opcjonalnie możemy użyć OR REPLACE, aby nadpisać istniejącą funkcję.
CREATE [OR REPLACE] FUNCTION nazwa_funkcji ([typ_funkcji])
RETURNS typ_wyniku_funkcji AS
    definicja_funkcji
LANGUAGE nazwa_języka;

-- Usuwanie funkcji --
-- Funkcję można usunąć za pomocą polecenia DROP FUNCTION.
DROP FUNCTION nazwa_funkcji([lista_typów]);

-- Wyszukiwanie funkcji --
-- Funkcje są przechowywane w tabeli systemowej pg_proc.
-- \df    -- Wyświetla listę funkcji użytkownika w psql
-- \d pg_proc    -- Wyświetla strukturę tabeli systemowej pg_proc
SELECT prosrc FROM pg_proc WHERE proname='nazwa_funkcji';  -- Wyświetla zawartość konkretnej procedury SQL

-- Tworzenie Funkcji w SQL --
-- Używamy języka SQL do tworzenia prostych funkcji. Parametry przekazujemy poprzez $1, $2, itd.
-- Przykład: Lista mieszkańców w wybranym mieście
CREATE FUNCTION lab.klienci_1(text)
RETURNS SETOF lab.customer AS $$
    SELECT * FROM lab.customer WHERE town=$1;
$$ LANGUAGE SQL;

-- Wywołanie funkcji lab.klienci_1 --
SELECT lab.klienci_1('Bingham');       -- Funkcja w kontekście argumentów
SELECT * FROM lab.klienci_1('Bingham'); -- Funkcja w kontekście źródła danych

-- Usunięcie funkcji --
DROP FUNCTION lab.klienci_1(text);

-- Funkcje w języku PL/pgSQL --
-- Język PL/pgSQL umożliwia deklarowanie zmiennych oraz stosowanie bloków kodu. Instrukcje są definiowane
-- za pomocą BEGIN...END oraz mogą zawierać pętle, warunki, oraz wyjątki.

-- Przykład: Funkcja licząca pole koła --
CREATE OR REPLACE FUNCTION lab.fun_1(int4) RETURNS float8 AS $$
DECLARE
    my_pi CONSTANT float8 = pi();
    r ALIAS FOR $1; -- Przekazany argument
BEGIN
    RETURN my_pi * r * r;
END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji lab.fun_1 --
SELECT lab.fun_1(10);

-- Obsługa błędów w PL/pgSQL --
-- Obsługę błędów realizujemy za pomocą polecenia RAISE, które pozwala na wysyłanie komunikatów do użytkownika lub logu.
DO $$
BEGIN
    RAISE INFO 'informacja: %', now();
    RAISE NOTICE 'ostrzeżenie: %', now();
END $$;

-- Pętle w PL/pgSQL --
-- PL/pgSQL oferuje kilka struktur pętli: LOOP, WHILE oraz FOR.

-- Przykład: Pętla LOOP --
DO $$
DECLARE
    i INTEGER := 0;
BEGIN
    LOOP
        EXIT WHEN i > 9;
        i := i + 1;
        RAISE NOTICE 'i: %', i;
    END LOOP;
END $$;

-- Przykład: Pętla WHILE --
DO $$
DECLARE
    i INTEGER := 0;
BEGIN
    WHILE i < 10 LOOP
        i := i + 1;
        RAISE NOTICE 'i: %', i;
    END LOOP;
END $$;

-- Funkcja z dynamicznym zapytaniem w PL/pgSQL --
CREATE OR REPLACE FUNCTION lab.fun_8(sort_type CHAR(1), n INTEGER)
RETURNS TABLE (im VARCHAR, naz VARCHAR, opis VARCHAR) AS $$
DECLARE
    query TEXT;
BEGIN
    query := 'SELECT fname AS im, lname AS naz, description AS opis FROM lab.customer JOIN lab.item USING (customer_id)';
    IF sort_type = 'U' THEN
        query := query || ' ORDER BY naz, opis';
    ELSIF sort_type = 'I' THEN
        query := query || ' ORDER BY opis, naz';
    ELSE
        RAISE EXCEPTION 'Niepoprawny typ sortowania %', sort_type;
    END IF;
    query := query || ' LIMIT ' || n;
    RETURN QUERY EXECUTE query;
END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji lab.fun_8 --
SELECT * FROM lab.fun_8('U', 12);
SELECT * FROM lab.fun_8('I', 7);
