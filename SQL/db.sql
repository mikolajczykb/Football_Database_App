DROP SCHEMA IF EXISTS football CASCADE;
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
		wynik_gospodarze INTEGER DEFAULT 0,
		wynik_goscie INTEGER DEFAULT 0,
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

