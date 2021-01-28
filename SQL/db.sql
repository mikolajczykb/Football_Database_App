CREATE SCHEMA football;

DROP TABLE IF EXISTS football.sedzia CASCADE;
CREATE TABLE football.sedzia (
		id_sedziego SERIAL,
		imie VARCHAR NOT NULL,
		nazwisko VARCHAR NOT NULL,
		data_urodzenia DATE NOT NULL,
		CONSTRAINT sedzia_pk PRIMARY KEY (id_sedziego)
);

DROP TABLE IF EXISTS football.druzyna CASCADE;
CREATE TABLE football.druzyna (
		id_druzyny SERIAL,
		nazwa VARCHAR NOT NULL,
		adres TEXT NOT NULL,
		liczba_punktow INTEGER DEFAULT 0 CHECK (liczba_punktow >= 0),
		wygrane INTEGER DEFAULT 0 CHECK (wygrane >= 0),
		remisy INTEGER DEFAULT 0 CHECK (remisy >= 0),
		przegrane INTEGER DEFAULT 0 CHECK (przegrane >= 0),
		CONSTRAINT druzyna_pk PRIMARY KEY (id_druzyny)
);

DROP TABLE IF EXISTS football.herb CASCADE;
CREATE TABLE football.herb (
		id_herbu SERIAL,
		id_druzyny INTEGER NOT NULL,
		date_from DATE NOT NULL,
		date_to DATE CHECK (date_from < date_to),
		CONSTRAINT herb_pk PRIMARY KEY (id_herbu),
		CONSTRAINT druzyna_fk 
			FOREIGN KEY (id_druzyny) 
				REFERENCES football.druzyna (id_druzyny)
				ON DELETE CASCADE
);

DROP TABLE IF EXISTS football.pilkarz CASCADE;
CREATE TABLE football.pilkarz (
		id_pilkarza SERIAL,
		id_druzyny INTEGER NOT NULL,
		numer_na_koszulce INTEGER NOT NULL CHECK (numer_na_koszulce > 0),
		imie VARCHAR NOT NULL,
		nazwisko VARCHAR NOT NULL,
		czy_czerwona BOOL DEFAULT FALSE,
		mecze_zawieszenia INTEGER DEFAULT 0,
		CONSTRAINT pilkarz_pk PRIMARY KEY (id_pilkarza),
		CONSTRAINT druzyna_fk 
			FOREIGN KEY (id_druzyny) 
				REFERENCES football.druzyna (id_druzyny)
				ON DELETE CASCADE
);

DROP TABLE IF EXISTS football.mecz CASCADE;
CREATE TABLE football.mecz (
		id_meczu SERIAL,
		id_gospodarza INTEGER NOT NULL,
		id_goscia INTEGER NOT NULL,
		data_meczu DATE NOT NULL,
		wynik_gospodarze INTEGER NOT NULL,
		wynik_goscie INTEGER NOT NULL,
		nr_kolejki INTEGER NOT NULL CHECK (nr_kolejki > 0),
		CONSTRAINT mecz_pk PRIMARY KEY (id_meczu),
		CONSTRAINT gospodarze_fk
			FOREIGN KEY (id_gospodarza)
				REFERENCES football.druzyna
				ON DELETE CASCADE,
		CONSTRAINT goscie_fk
			FOREIGN KEY (id_goscia)
				REFERENCES football.druzyna
				ON DELETE CASCADE
);

DROP TABLE IF EXISTS football.rola CASCADE;
CREATE TABLE football.rola (
		id_meczu INTEGER NOT NULL REFERENCES football.mecz,
		id_sedziego INTEGER NOT NULL REFERENCES football.sedzia,
		czy_glowny BOOL DEFAULT FALSE,
		CONSTRAINT rola_pk PRIMARY KEY (id_meczu, id_sedziego),
		CONSTRAINT mecz_fk FOREIGN KEY (id_meczu) REFERENCES football.mecz (id_meczu)
			ON DELETE CASCADE,
		CONSTRAINT sedzia_fk FOREIGN KEY (id_sedziego) REFERENCES football.sedzia (id_sedziego)
			ON DELETE CASCADE
);

DROP TABLE IF EXISTS football.pilkarz_mecz CASCADE;
CREATE TABLE football.pilkarz_mecz (
		id_meczu INTEGER NOT NULL REFERENCES football.mecz,
		id_pilkarza INTEGER NOT NULL REFERENCES football.pilkarz,
		czy_zmiennik BOOL DEFAULT FALSE,
		poczatek_gry INTEGER NOT NULL CHECK (poczatek_gry >= 0 AND poczatek_gry < 90),
		koniec_gry INTEGER NOT NULL CHECK (poczatek_gry < koniec_gry AND koniec_gry > 0),
		CONSTRAINT pilkarz_mecz_pk PRIMARY KEY (id_meczu, id_pilkarza),
		CONSTRAINT mecz_fk FOREIGN KEY (id_meczu) REFERENCES football.mecz (id_meczu)
			ON DELETE CASCADE,
		CONSTRAINT pilkarz_fk FOREIGN KEY (id_pilkarza) REFERENCES football.pilkarz (id_pilkarza)
			ON DELETE CASCADE
);

DROP TABLE IF EXISTS football.kartka CASCADE;
CREATE TABLE football.kartka (
		id_kartki SERIAL,
		id_meczu INTEGER NOT NULL,
		id_pilkarza INTEGER NOT NULL,
		minuta INTEGER NOT NULL CHECK (minuta > 0),
		czy_zolta BOOL DEFAULT TRUE,
		czy_czerwona BOOL DEFAULT FALSE,
		CONSTRAINT kartka_pk PRIMARY KEY (id_kartki),
		CONSTRAINT pilkarz_mecz_fk1
			FOREIGN KEY (id_meczu)
				REFERENCES football.mecz (id_meczu)
				ON DELETE CASCADE,
		CONSTRAINT pilkarz_mecz_fk2
			FOREIGN KEY (id_pilkarza)
				REFERENCES football.pilkarz (id_pilkarza)
				ON DELETE CASCADE
);


DROP TABLE IF EXISTS football.asysta CASCADE;
CREATE TABLE football.asysta (
		id_asysty SERIAL,
		id_meczu INTEGER NOT NULL,
		id_pilkarza INTEGER NOT NULL,
		minuta INTEGER NOT NULL CHECK (minuta > 0),
		CONSTRAINT pilkarz_mecz_fk1
			FOREIGN KEY (id_meczu)
				REFERENCES football.mecz (id_meczu)
				ON DELETE CASCADE,
		CONSTRAINT pilkarz_mecz_fk2
			FOREIGN KEY (id_pilkarza)
				REFERENCES football.pilkarz (id_pilkarza)
				ON DELETE CASCADE
);

DROP TABLE IF EXISTS football.bramki CASCADE;
CREATE TABLE football.bramki (
		id_bramki SERIAL,
		id_meczu INTEGER NOT NULL,
		id_pilkarza INTEGER NOT NULL,
		minuta INTEGER NOT NULL CHECK (minuta > 0),
		czy_karny BOOL DEFAULT FALSE,
		czy_samoboj BOOL DEFAULT FALSE,
		CONSTRAINT pilkarz_mecz_fk1
			FOREIGN KEY (id_meczu)
				REFERENCES football.mecz (id_meczu)
				ON DELETE CASCADE,
		CONSTRAINT pilkarz_mecz_fk2
			FOREIGN KEY (id_pilkarza)
				REFERENCES football.pilkarz (id_pilkarza)
				ON DELETE CASCADE
);

SET SEARCH_PATH TO football;

INSERT INTO druzyna (nazwa, adres) VALUES ('Arsenal', 'Emirates Stadium, London');
INSERT INTO druzyna (nazwa, adres) VALUES ('Manchester United', 'Old Trafford, Manchester');
INSERT INTO druzyna (nazwa, adres) VALUES ('Liverpool', 'Anfield, Liverpool');
INSERT INTO druzyna (nazwa, adres) VALUES ('Leicester City', 'King Power Stadium, Leicester');
INSERT INTO druzyna (nazwa, adres) VALUES ('Everton', 'Goodison Park, Liverpool');
INSERT INTO druzyna (nazwa, adres) VALUES ('Tottenham Hotspur', 'Tottenham Hotspur Stadium, London');
INSERT INTO druzyna (nazwa, adres) VALUES ('Manchester City', 'Tottenham Hotspur Stadium, London');
INSERT INTO druzyna (nazwa, adres) VALUES ('Aston Villa', 'Villa Park, Birmingham');
INSERT INTO druzyna (nazwa, adres) VALUES ('Chelsea', 'Stamford Bridge, London');
INSERT INTO druzyna (nazwa, adres) VALUES ('West Ham', 'London Stadium, London');
INSERT INTO druzyna (nazwa, adres) VALUES ('West Bromwich Albion', 'The Hawthorns, West Bromwich');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (1, '1', 'Bernd', 'Leno'),
(1, '3', 'Kieran', 'Tierney'),
(1, '16', 'Rob', 'Holding'),
(1, '6', 'Gabriel', 'Magalhaes'),
(1, '2', 'Hector', 'Bellerin'),
(1, '18', 'Thomas', 'Partey'),
(1, '8', 'Dani', 'Ceballos'),
(1, '32', 'Emile', 'Smith-Rowe'),
(1, '7', 'Bukayo', 'Saka'),
(1, '9', 'Alexandre', 'Lacazette'),
(1, '14', 'Pierre-Emerick', 'Aubameyang'),
(1, '15', 'Ainsley', 'Maitland-Niles'),
(1, '33', 'Mohamed', 'Elneny'),
(1, '12', 'Willian', 'Borghes');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '1', 'David', 'De Gea');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '3', 'Luke', 'Shaw');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '16', 'Harry', 'Maguire');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '6', 'Eric', 'Bailly');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '2', 'Aaron', 'Wan Bissaka');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '18', 'Scott', 'McTominay');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '8', 'Paul', 'Pogba');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '32', 'Fred', 'Whoevenknows');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '7', 'Marcus', 'Rashford');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '9', 'Anthony', 'Martial');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '14', 'Bruno', 'Fernandes');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '15', 'Daniel', 'James');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '33', 'Mason', 'Greenwood');
INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (2, '12', 'Victor', 'Lindelof');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (3, '1', 'Alisson', 'Borges'),
(3, '3', 'Andrew', 'Robertson'),
(3, '16', 'Virgil', 'Van Dijk'),
(3, '6', 'Joseph', 'Gomez'),
(3, '2', 'Trent', 'Alexander-Arnold'),
(3, '18', 'Georginio', 'Wijnaldum'),
(3, '8', 'Thiago', 'Alcantara'),
(3, '32', 'Jordan', 'Henderson'),
(3, '7', 'Mohamed', 'Salah'),
(3, '9', 'Sadio', 'Mane'),
(3, '14', 'Roberto', 'Firmino'),
(3, '15', 'Naby', 'Keita'),
(3, '33', 'Diogo', 'Jota'),
(3, '12', 'Divock', 'Origi');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (4, '1', 'Kasper', 'Schmeichel'),
(4, '3', 'Christian', 'Fuchs'),
(4, '16', 'Caglar', 'Soyuncu'),
(4, '6', 'Jonny', 'Evans'),
(4, '2', 'Ricardo', 'Pereira'),
(4, '18', 'Youri', 'Tielemans'),
(4, '8', 'Wilfred', 'Ndidi'),
(4, '32', 'Marc', 'Albrighton'),
(4, '7', 'James', 'Maddison'),
(4, '9', 'Demarai', 'Gray'),
(4, '14', 'Ayoze', 'Perez'),
(4, '15', 'Kelechi', 'Iheanacho'),
(4, '33', 'Islam', 'Slimani'),
(4, '12', 'James', 'Vardy');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (5, '1', 'Jordan', 'Pickford'),
(5, '16', 'Lucas', 'Digne'),
(5, '6', 'Michael', 'Keane'),
(5, '2', 'Yerry', 'Mina'),
(5, '3', 'Seamus', 'Coleman'),
(5, '18', 'Andres', 'Gomes'),
(5, '8', 'James', 'Rodriguez'),
(5, '32', 'Abdoulaye', 'Doucoure'),
(5, '7', 'Alex', 'Iwobi'),
(5, '9', 'Richarlison', 'de Andrade'),
(5, '14', 'Dominic', 'Calvert-Lewin'),
(5, '15', 'Bernard', 'Braziliano'),
(5, '33', 'Cenk', 'Tosun'),
(5, '12', 'Yannick', 'Bolasie');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (6, '1', 'Hugo', 'Lloris'),
(6, '3', 'Ben', 'Davies'),
(6, '16', 'Toby', 'Alderweireld'),
(6, '6', 'Davidson', 'Sanchez'),
(6, '2', 'Serge', 'Aurier'),
(6, '18', 'Eric', 'Dier'),
(6, '8', 'Moussa', 'Sissoko'),
(6, '32', 'Tanguy', 'Ndombele'),
(6, '7', 'Dele', 'Alli'),
(6, '9', 'Son', 'Heung-Min'),
(6, '14', 'Harry', 'Kane'),
(6, '15', 'Lucas', 'Moura'),
(6, '33', 'Pierre-Emile', 'Hojbjerg'),
(6, '12', 'Erik', 'Lamela');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (7, '1', 'Ederson', 'da Silva'),
(7, '3', 'Kyle', 'Walker'),
(7, '16', 'John', 'Stones'),
(7, '6', 'Aymeric', 'Laporte'),
(7, '2', 'Joao', 'Cancelo'),
(7, '18', 'Kevin', 'De Bruyne'),
(7, '8', 'Bernardo', 'Silva'),
(7, '32', 'Ilkay', 'Gundogan'),
(7, '7', 'Raheem', 'Sterling'),
(7, '9', 'Sergio', 'Aguero'),
(7, '14', 'Riyad', 'Mahrez'),
(7, '15', 'Ferran', 'Torres'),
(7, '33', 'Gabriel', 'Jesus'),
(7, '12', 'Oleksandr', 'Zinchenko');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (8, '1', 'Emiliano', 'Martinez'),
(8, '3', 'Matt', 'Targett'),
(8, '16', 'Tyrone', 'Mings'),
(8, '6', 'Matthew', 'Cash'),
(8, '2', 'Kortney', 'Hause'),
(8, '18', 'John', 'McGinn'),
(8, '8', 'Jack', 'Grealish'),
(8, '32', 'Ross', 'Barkley'),
(8, '7', 'Ollie', 'Watkins'),
(8, '9', 'Bertrand', 'Traore'),
(8, '14', 'Anwar', 'El Ghazi'),
(8, '15', 'Douglas', 'Luiz'),
(8, '33', 'Marvelous', 'Nakamba'),
(8, '12', 'Conor', 'Hourihane');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (9, '1', 'Ferland', 'Mendy'),
(9, '3', 'Ben', 'Chillwell'),
(9, '16', 'Kurt', 'Zouma'),
(9, '6', 'Thiago', 'Silva'),
(9, '2', 'Reece', 'James'),
(9, '18', 'Kai', 'Havertz'),
(9, '8', 'Mason', 'Mount'),
(9, '32', 'Ngolo', 'Kante'),
(9, '7', 'Christian', 'Pulisic'),
(9, '9', 'Olivier', 'Giroud'),
(9, '14', 'Timo', 'Werner'),
(9, '15', 'Tammy', 'Abraham'),
(9, '33', 'Diogo', 'Jota'),
(9, '12', 'Hakim', 'Ziyech');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (10, '1', 'Lukasz', 'Fabianski'),
(10, '16', 'Aaron', 'Cresswell'),
(10, '6', 'Angelo', 'Ogbonna'),
(10, '2', 'Issa', 'Diop'),
(10, '3', 'Arthur', 'Masuaku'),
(10, '18', 'Declan', 'Rice'),
(10, '8', 'Tomas', 'Soucek'),
(10, '32', 'Manuel', 'Lanzini'),
(10, '7', 'Pablo', 'Fornals'),
(10, '9', 'Michail', 'Antinio'),
(10, '14', 'Andriy', 'Yarmolenko'),
(10, '15', 'Said', 'Benrahma'),
(10, '33', 'Vladimir', 'Coufal'),
(10, '12', 'Mark', 'Noble');

INSERT INTO pilkarz(id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES (11, '1', 'Sam', 'Johnstone'),
(11, '16', 'Darnell', 'Furlong'),
(11, '6', 'Kieran', 'Gibbs'),
(11, '2', 'Semi', 'Ajayi'),
(11, '3', 'Kyle', 'Bartley'),
(11, '18', 'Kamil', 'Grosicki'),
(11, '8', 'Matt', 'Phillips'),
(11, '32', 'Jake', 'Livermore'),
(11, '7', 'Robert', 'Snodgrass'),
(11, '9', 'Matheus', 'Pereira'),
(11, '14', 'Callum', 'Robinson'),
(11, '15', 'Hal', 'Robson-Kanu'),
(11, '33', 'Grady', 'Diangana'),
(11, '12', 'Karlan', 'Grant');

INSERT INTO football.sedzia (imie, nazwisko, data_urodzenia) VALUES ('Martin', 'Atkinson', '1971-03-31');
INSERT INTO football.sedzia (imie, nazwisko, data_urodzenia) VALUES ('Michael', 'Oliver', '1985-02-20');

INSERT INTO football.mecz (id_gospodarza, id_goscia, data_meczu, wynik_gospodarze, wynik_goscie, nr_kolejki)
	VALUES (1, 2, '2020-11-01', 1, 0, 1);

INSERT INTO football.rola (id_meczu, id_sedziego, czy_glowny) VALUES (1, 1, TRUE);

INSERT INTO football.pilkarz_mecz (id_meczu, id_pilkarza, czy_zmiennik, poczatek_gry, koniec_gry) VALUES (1, 11, FALSE, 0, 90);
INSERT INTO football.pilkarz_mecz (id_meczu, id_pilkarza, czy_zmiennik, poczatek_gry, koniec_gry) VALUES (1, 10, FALSE, 0, 90);


INSERT INTO football.bramki (id_meczu, id_pilkarza, minuta, czy_karny, czy_samoboj) VALUES (1, 11, 69, FALSE, FALSE);

INSERT INTO football.asysta (id_meczu, id_pilkarza, minuta)
	VALUES (1, 11, 69);

INSERT INTO football.kartka (id_meczu, id_pilkarza, czy_zolta, czy_czerwona, minuta)
	VALUES (1, 11, TRUE, FALSE, 69);

	INSERT INTO football.kartka (id_meczu, id_pilkarza, czy_zolta, czy_czerwona, minuta)
	VALUES (1, 11, TRUE, FALSE, 90);