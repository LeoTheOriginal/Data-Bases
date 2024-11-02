-- Usunięcie istniejącego schematu i typów, jeśli istnieją
DROP SCHEMA IF EXISTS municipal_public_transport CASCADE;
DROP TYPE IF EXISTS vehicle_type, direction_type, stop_type, day_type;

-- Ustawienie formatu daty
SET DATESTYLE TO EUROPEAN;

-- Utworzenie schematu
CREATE SCHEMA municipal_public_transport;

-- Utworzenie typów ENUM
CREATE TYPE vehicle_type AS ENUM ('bus', 'tram');
CREATE TYPE direction_type AS ENUM ('outbound', 'inbound'); -- Uproszczono do dwóch kierunków
CREATE TYPE stop_type AS ENUM ('bus', 'tram', 'bus_and_tram');
CREATE TYPE day_type AS ENUM ('mon-fri', 'sat', 'sun');

-- Tabela 'stop' (Przystanki)
CREATE TABLE municipal_public_transport.stop (
    stop_id         SERIAL          PRIMARY KEY,
    name            VARCHAR(64)     NOT NULL,
    type            stop_type       NOT NULL
);

-- Tabela 'line' (Linie) z 'vehicle_type' przypisanym do linii
CREATE TABLE municipal_public_transport.line (
    line_id         SERIAL          PRIMARY KEY,
    line_number     INTEGER         NOT NULL UNIQUE,
    vehicle_type    vehicle_type    NOT NULL
);

-- Tabela 'route' (Trasy) bez 'vehicle_type' i z uproszczonym 'direction_type'
CREATE TABLE municipal_public_transport.route (
    route_id        SERIAL          PRIMARY KEY,
    line_id         INTEGER         NOT NULL,
    direction       direction_type  NOT NULL,
    start_stop_id   INTEGER         NOT NULL,
    end_stop_id     INTEGER         NOT NULL,
    CONSTRAINT route_line_fk FOREIGN KEY (line_id) REFERENCES municipal_public_transport.line(line_id),
    CONSTRAINT route_start_stop_fk FOREIGN KEY (start_stop_id) REFERENCES municipal_public_transport.stop(stop_id),
    CONSTRAINT route_end_stop_fk FOREIGN KEY (end_stop_id) REFERENCES municipal_public_transport.stop(stop_id),
    CONSTRAINT route_direction_check CHECK (direction IN ('outbound', 'inbound'))
);

-- Tabela 'stop_in_route' (Przystanki na trasie)
CREATE TABLE municipal_public_transport.stop_in_route (
    stop_in_route_id    SERIAL          PRIMARY KEY,
    route_id            INTEGER         NOT NULL,
    stop_id             INTEGER         NOT NULL,
    stop_order          INTEGER         NOT NULL,
    time_offset         INTEGER         NOT NULL, -- Czas w minutach od startu trasy
    CONSTRAINT stop_in_route_route_fk FOREIGN KEY (route_id) REFERENCES municipal_public_transport.route(route_id),
    CONSTRAINT stop_in_route_stop_fk FOREIGN KEY (stop_id) REFERENCES municipal_public_transport.stop(stop_id)
);

-- Tabela 'schedule' (Harmonogramy)
CREATE TABLE municipal_public_transport.schedule (
    schedule_id     SERIAL          PRIMARY KEY,
    route_id        INTEGER         NOT NULL,
    day             day_type        NOT NULL,
    start_time      TIME            NOT NULL,
    end_time        TIME            NOT NULL,
    frequency       INTEGER         NOT NULL,
    CONSTRAINT schedule_route_fk FOREIGN KEY (route_id) REFERENCES municipal_public_transport.route(route_id)   --Odjazdy z Salwator rozpoczynają się o godzinie 5:00 rano i kończą o 23:00.
                                                                                                                --Odjazdy z Kurdwanów P+R mogą rozpoczynać się wcześniej lub później, np. od 5:30 do 23:30.
);

-- Tabela 'departure' (Odjazdy)
CREATE TABLE municipal_public_transport.departure (
    departure_id        SERIAL          PRIMARY KEY,
    stop_in_route_id    INTEGER         NOT NULL,
    schedule_id         INTEGER         NOT NULL,
    departure_time      TIME            NOT NULL,
    CONSTRAINT departure_stop_in_route_fk FOREIGN KEY (stop_in_route_id) REFERENCES municipal_public_transport.stop_in_route(stop_in_route_id),
    CONSTRAINT departure_schedule_fk FOREIGN KEY (schedule_id) REFERENCES municipal_public_transport.schedule(schedule_id),
    CONSTRAINT departure_unique_constraint UNIQUE (stop_in_route_id, schedule_id, departure_time)
);

-- Tabela 'ticket_type' (Typy Biletów)
CREATE TABLE municipal_public_transport.ticket_type (
    ticket_type_id  SERIAL          PRIMARY KEY,
    name            VARCHAR(32)     NOT NULL,  -- np. 'normalny', 'ulgowy'
    description     TEXT
);

-- Tabela 'discount' (Ulgi)
CREATE TABLE municipal_public_transport.discount (
    discount_id     SERIAL          PRIMARY KEY,
    name            VARCHAR(32)     NOT NULL,  -- np. 'studencka', 'senior'
    percentage      NUMERIC(5,2)    NOT NULL   -- Procent zniżki
);

-- Tabela 'ticket' (Bilety)
CREATE TABLE municipal_public_transport.ticket (
    ticket_id       SERIAL          PRIMARY KEY,
    ticket_type_id  INTEGER         NOT NULL,
    discount_id     INTEGER,                    -- Może być NULL, jeśli brak ulgi
    validity_start  TIMESTAMP       NOT NULL,
    validity_end    TIMESTAMP       NOT NULL,
    price           NUMERIC(10,2)   NOT NULL,
    CONSTRAINT ticket_ticket_type_fk FOREIGN KEY (ticket_type_id) REFERENCES municipal_public_transport.ticket_type(ticket_type_id),
    CONSTRAINT ticket_discount_fk FOREIGN KEY (discount_id) REFERENCES municipal_public_transport.discount(discount_id)
);

-- Dodanie przystanków do tabeli "stop"
INSERT INTO municipal_public_transport.stop (name, type) VALUES
    ('Dworzec Główny Zachód', 'bus_and_tram'),
    ('Salwator', 'tram'),
    ('Kurdwanów P+R', 'bus_and_tram'),
    ('Bronowice Małe', 'tram'),
    ('Nowy Kleparz', 'bus_and_tram'),
    ('Plac Inwalidów', 'bus_and_tram'),
    ('Rondo Mogilskie', 'bus_and_tram'),
    ('Plac Centralny', 'bus_and_tram'),
    ('Ruczaj', 'tram'),
    ('Dębniki', 'bus_and_tram'),
    ('Borek Fałęcki', 'bus_and_tram'),
    ('Krowodrza Górka', 'bus_and_tram'),
    ('Czerwone Maki P+R', 'bus_and_tram'),
    ('Mistrzejowice', 'bus_and_tram'),
    ('Osiedle Piastów', 'bus'),
    ('Wzgórza Krzesławickie', 'tram'),
    ('Pleszów', 'tram'),
    ('Prokocim', 'bus_and_tram'),
    ('Wieliczka Rynek Kopalnia', 'bus_and_tram'),
    ('Bieżanów Nowy', 'bus_and_tram'),
    ('Czyżyny', 'bus_and_tram'),
    ('Aleja Pokoju', 'bus_and_tram'),
    ('Łagiewniki', 'bus_and_tram'),
    ('Nowy Bieżanów P+R', 'bus_and_tram'),
    ('Podgórze SKA', 'bus_and_tram'),
    ('Rondo Grzegórzeckie', 'bus_and_tram'),
    ('Plac Bohaterów Getta', 'bus_and_tram'),
    ('Dietla', 'tram'),
    ('Teatr Bagatela', 'tram'),
    ('Plac Wszystkich Świętych', 'tram'),
    ('Filharmonia', 'tram');

-- Dodanie linii do tabeli "line"
INSERT INTO municipal_public_transport.line (line_number, vehicle_type) VALUES
    (1, 'tram'),
    (4, 'tram'),
    (8, 'tram'),
    (13, 'tram'),
    (18, 'tram'),
    (24, 'tram'),
    (50, 'tram'),
    (52, 'tram'),
    (69, 'tram'),    -- Linia z różnymi trasami inbound/outbound
    (144, 'bus'),
    (164, 'bus'),
    (169, 'bus'),
    (179, 'bus'),
    (194, 'bus'),
    (501, 'bus'),
    (503, 'bus'),
    (511, 'bus');

-- Trasy dla linii 1
INSERT INTO municipal_public_transport.route (line_id, direction, start_stop_id, end_stop_id) VALUES
    ((SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1), 'outbound',
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Salwator'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Kurdwanów P+R')),
    ((SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1), 'inbound',
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Kurdwanów P+R'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Salwator'));

-- Trasy dla linii 69 z różnymi trasami
-- Outbound: z Mistrzejowic do Krowodrzy Górki przez Plac Centralny
INSERT INTO municipal_public_transport.route (line_id, direction, start_stop_id, end_stop_id) VALUES
    ((SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69), 'outbound',
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Mistrzejowice'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Krowodrza Górka'));

-- Inbound: z Krowodrzy Górki do Mistrzejowic przez Dworzec Główny Zachód
INSERT INTO municipal_public_transport.route (line_id, direction, start_stop_id, end_stop_id) VALUES
    ((SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69), 'inbound',
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Krowodrza Górka'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Mistrzejowice'));

-- Trasy dla pozostałych linii (przykładowo dla linii 4)
INSERT INTO municipal_public_transport.route (line_id, direction, start_stop_id, end_stop_id) VALUES
    ((SELECT line_id FROM municipal_public_transport.line WHERE line_number = 4), 'outbound',
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Bronowice Małe'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Wzgórza Krzesławickie')),
    ((SELECT line_id FROM municipal_public_transport.line WHERE line_number = 4), 'inbound',
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Wzgórza Krzesławickie'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Bronowice Małe'));

-- Podobnie dodaj trasy dla pozostałych linii...




-- Przystanki dla trasy 'outbound' linii 1
INSERT INTO municipal_public_transport.stop_in_route (route_id, stop_id, stop_order, time_offset) VALUES
    -- Pobieramy route_id dla linii 1 i kierunku 'outbound'
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Salwator'), 1, 0),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Filharmonia'), 2, 3),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Wszystkich Świętych'), 3, 5),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Teatr Bagatela'), 4, 7),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Dietla'), 5, 10),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Bohaterów Getta'), 6, 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Kurdwanów P+R'), 7, 25);

-- Przystanki dla trasy 'inbound' linii 1
INSERT INTO municipal_public_transport.stop_in_route (route_id, stop_id, stop_order, time_offset) VALUES
    -- Poprawne pobieranie route_id dla linii 1 i kierunku 'inbound'
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Kurdwanów P+R'), 1, 0),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Bohaterów Getta'), 2, 10),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Dietla'), 3, 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Teatr Bagatela'), 4, 18),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Wszystkich Świętych'), 5, 20),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Filharmonia'), 6, 22),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Salwator'), 7, 25);


-- Przystanki dla trasy 'outbound' linii 69
INSERT INTO municipal_public_transport.stop_in_route (route_id, stop_id, stop_order, time_offset) VALUES
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Mistrzejowice'), 1, 0),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Centralny'), 2, 7),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Rondo Mogilskie'), 3, 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Dworzec Główny Zachód'), 4, 18),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Nowy Kleparz'), 5, 22),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Krowodrza Górka'), 6, 30);

-- Przystanki dla trasy 'inbound' linii 69
INSERT INTO municipal_public_transport.stop_in_route (route_id, stop_id, stop_order, time_offset) VALUES
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Krowodrza Górka'), 1, 0),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Nowy Kleparz'), 2, 8),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Inwalidów'), 3, 12),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Dworzec Główny Zachód'), 4, 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Rondo Mogilskie'), 5, 18),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Plac Centralny'), 6, 25),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     (SELECT stop_id FROM municipal_public_transport.stop WHERE name = 'Mistrzejowice'), 7, 32);

-- Podobnie dodaj przystanki dla pozostałych tras...




-- Harmonogram dla trasy 'outbound' linii 1
INSERT INTO municipal_public_transport.schedule (route_id, day, start_time, end_time, frequency) VALUES
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     'mon-fri', '05:00', '23:00', 10),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     'sat', '06:00', '23:00', 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'outbound'),
     'sun', '07:00', '22:00', 20);

-- Harmonogram dla trasy 'inbound' linii 1
INSERT INTO municipal_public_transport.schedule (route_id, day, start_time, end_time, frequency) VALUES
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     'mon-fri', '05:30', '23:30', 10),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     'sat', '06:30', '23:30', 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1) AND direction = 'inbound'),
     'sun', '07:30', '22:30', 20);

-- Harmonogram dla trasy 'outbound' linii 69
INSERT INTO municipal_public_transport.schedule (route_id, day, start_time, end_time, frequency) VALUES
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     'mon-fri', '05:15', '22:45', 12),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     'sat', '06:15', '23:15', 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'outbound'),
     'sun', '07:15', '22:15', 20);

-- Harmonogram dla trasy 'inbound' linii 69
INSERT INTO municipal_public_transport.schedule (route_id, day, start_time, end_time, frequency) VALUES
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     'mon-fri', '05:45', '23:15', 12),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     'sat', '06:45', '23:45', 15),
    ((SELECT route_id FROM municipal_public_transport.route WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 69) AND direction = 'inbound'),
     'sun', '07:45', '22:45', 20);


-- Poniżej przykład dla jednego odjazdu
INSERT INTO municipal_public_transport.departure (stop_in_route_id, schedule_id, departure_time)
SELECT
    sir.stop_in_route_id,
    sch.schedule_id,
    (sch.start_time + (n * sch.frequency * INTERVAL '1 minute') + (sir.time_offset * INTERVAL '1 minute'))::TIME AS departure_time
FROM municipal_public_transport.schedule sch
JOIN municipal_public_transport.stop_in_route sir ON sir.route_id = sch.route_id
CROSS JOIN generate_series(0,
    ((EXTRACT(EPOCH FROM (sch.end_time - sch.start_time)) / 60) / sch.frequency)::INT
) AS n
WHERE sch.route_id = (
    SELECT route_id
    FROM municipal_public_transport.route
    WHERE line_id = (SELECT line_id FROM municipal_public_transport.line WHERE line_number = 1)
      AND direction = 'outbound'
)
AND sch.day = 'mon-fri'
ON CONFLICT (stop_in_route_id, schedule_id, departure_time) DO NOTHING;


INSERT INTO municipal_public_transport.ticket_type (name, description) VALUES
    ('normalny', 'Bilet normalny bez zniżki'),
    ('ulgowy', 'Bilet ulgowy z obniżoną ceną');

INSERT INTO municipal_public_transport.discount (name, percentage) VALUES
    ('studencka', 50.00), -- Zniżka 50%
    ('senior', 30.00);    -- Zniżka 30%

INSERT INTO municipal_public_transport.ticket (ticket_type_id, discount_id, validity_start, validity_end, price) VALUES
    ((SELECT ticket_type_id FROM municipal_public_transport.ticket_type WHERE name = 'normalny'), NULL, '2023-11-02 00:00:00', '2023-11-02 23:59:59', 4.00),
    ((SELECT ticket_type_id FROM municipal_public_transport.ticket_type WHERE name = 'ulgowy'), (SELECT discount_id FROM municipal_public_transport.discount WHERE name = 'studencka'), '2023-11-02 00:00:00', '2023-11-02 23:59:59', 2.00);

--dla wybranego przystanku -> znaleźć linie zatrzymujące się na tym przystanku,
SELECT DISTINCT l.line_number, l.vehicle_type
FROM municipal_public_transport.line l
JOIN municipal_public_transport.route r ON l.line_id = r.line_id
JOIN municipal_public_transport.stop_in_route sir ON r.route_id = sir.route_id
JOIN municipal_public_transport.stop s ON sir.stop_id = s.stop_id
WHERE s.name = 'Plac Bohaterów Getta';


--dla wybranego przystanku i linii -> znaleźć czasy odjazdu,
SELECT d.departure_time, l.line_number, s.name AS stop_name, r.direction, sch.day
FROM municipal_public_transport.departure d
JOIN municipal_public_transport.stop_in_route sir ON d.stop_in_route_id = sir.stop_in_route_id
JOIN municipal_public_transport.route r ON sir.route_id = r.route_id
JOIN municipal_public_transport.line l ON r.line_id = l.line_id
JOIN municipal_public_transport.stop s ON sir.stop_id = s.stop_id
JOIN municipal_public_transport.schedule sch ON d.schedule_id = sch.schedule_id
WHERE s.name = 'Plac Bohaterów Getta' AND l.line_number = 1
ORDER BY d.departure_time;

--dla wybranej linii - znaleźć przystanki i czasy odjazdu z przystanków
SELECT l.line_number, s.name AS stop_name, r.direction, d.departure_time, sch.day
FROM municipal_public_transport.line l
JOIN municipal_public_transport.route r ON l.line_id = r.line_id
JOIN municipal_public_transport.stop_in_route sir ON r.route_id = sir.route_id
JOIN municipal_public_transport.stop s ON sir.stop_id = s.stop_id
JOIN municipal_public_transport.departure d ON sir.stop_in_route_id = d.stop_in_route_id
JOIN municipal_public_transport.schedule sch ON d.schedule_id = sch.schedule_id
WHERE l.line_number = 1
ORDER BY r.direction, sir.stop_order, d.departure_time;