
/* Trigger do aktualizowania przy kartkach */

CREATE OR REPLACE FUNCTION kartka_trigger() RETURNS TRIGGER AS $$
DECLARE
	pilkarz_dane RECORD;
	kartka_dane RECORD;
BEGIN
	SELECT * INTO pilkarz_dane FROM football.pilkarz_mecz WHERE NEW.id_meczu =
	football.pilkarz_mecz.id_meczu AND NEW.id_pilkarza = football.pilkarz_mecz.id_pilkarza;

	IF NEW.minuta NOT BETWEEN pilkarz_dane.poczatek_gry AND pilkarz_dane.koniec_gry THEN
		RAISE EXCEPTION 'Podano zła minute kartki!';
		RETURN NULL;
	END IF;

	SELECT * INTO kartka_dane FROM football.kartka WHERE NEW.id_meczu = football.kartka.id_meczu AND
	NEW.id_pilkarza = football.kartka.id_pilkarza;
	
	IF kartka_dane.czy_czerwona = TRUE THEN
		RAISE EXCEPTION 'Pilkarz nie moze otrzymac dwoch czerwonych kartek!';
		RETURN NULL;
	ELSIF kartka_dane.czy_zolta = TRUE THEN
		UPDATE football.pilkarz SET czy_czerwona = TRUE, mecze_zawieszenia = 1
		WHERE football.pilkarz.id_pilkarza = NEW.id_pilkarza;
	ELSE
		IF NEW.czy_czerwona = FALSE and NEW.czy_zolta = FALSE THEN
			RAISE EXCEPTION 'Kartka musi byc zolta lub czerwona!';
			RETURN NULL;
		ELSIF NEW.czy_czerwona = TRUE THEN
			UPDATE football.pilkarz SET czy_czerwona = TRUE, mecze_zawieszenia = 3
			WHERE football.pilkarz.id_pilkarza = NEW.id_pilkarza;
		END IF;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

	
CREATE TRIGGER trigger_kartka BEFORE INSERT OR UPDATE ON football.kartka
FOR ROW EXECUTE PROCEDURE kartka_trigger();



/* Trigger do aktualizowania punktów */

CREATE OR REPLACE FUNCTION add_points() RETURNS TRIGGER AS $$
DECLARE
	goscie RECORD;
	gospodarze RECORD;
BEGIN
	SELECT * INTO goscie FROM football.druzyna WHERE NEW.id_goscia = football.druzyna.id_druzyny;
	SELECT * INTO gospodarze FROM football.druzyna WHERE NEW.id_gospodarza = football.druzyna.id_druzyny;
	IF NEW.wynik_gospodarze > NEW.wynik_goscie THEN
		UPDATE football.druzyna SET liczba_punktow = gospodarze.liczba_punktow + 3, wygrane = gospodarze.wygrane + 1 WHERE NEW.id_gospodarza = football.druzyna.id_druzyny;
		UPDATE football.druzyna SET przegrane = goscie.przegrane + 1 WHERE NEW.id_goscia = football.druzyna.id_druzyny;
	ELSIF NEW.wynik_goscie = NEW.wynik_gospodarze THEN
		UPDATE football.druzyna SET liczba_punktow = gospodarze.liczba_punktow + 1, remisy = gospodarze.remisy + 1 WHERE NEW.id_gospodarza = football.druzyna.id_druzyny;
		UPDATE football.druzyna SET liczba_punktow = goscie.liczba_punktow + 1, remisy = goscie.remisy + 1 WHERE NEW.id_goscia = football.druzyna.id_druzyny;
	ELSE
		UPDATE football.druzyna SET liczba_punktow = goscie.liczba_punktow + 3, wygrane = goscie.wygrane + 1 WHERE NEW.id_goscia = football.druzyna.id_druzyny;
		UPDATE football.druzyna SET przegrane = gospodarze.przegrane + 1 WHERE NEW.id_gospodarza = football.druzyna.id_druzyny;
	END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_punkty AFTER INSERT OR UPDATE ON football.mecz
FOR ROW EXECUTE PROCEDURE add_points();


/* Trigger do aktualizowania meczów zawieszenia piłkarzy */

CREATE OR REPLACE FUNCTION decrease_matches_left() RETURNS TRIGGER AS $$
DECLARE
	pilkarz RECORD;
BEGIN
	FOR pilkarz IN (SELECT * FROM football.pilkarz WHERE football.pilkarz.id_pilkarza = NEW.id_goscia) LOOP
		IF pilkarz.mecze_zawieszenia > 0 THEN
			UPDATE football.pilkarz SET mecze_zawieszenia = pilkarz.mecze_zawieszenia - 1 WHERE football.pilkarz.id_pilkarza = NEW.id_goscia;
		ELSIF pilkarz.mecze_zawieszenia = 0 AND pilkarz.czy_czerwona = TRUE THEN
			UPDATE football.pilkarz SET czy_czerwona = FALSE WHERE football.pilkarz.id_pilkarza = NEW.id_goscia;
		END IF;
	END LOOP;
	FOR pilkarz IN (SELECT * FROM football.pilkarz WHERE football.pilkarz.id_pilkarza = NEW.id_gospodarza) LOOP
		IF pilkarz.mecze_zawieszenia > 0 THEN
			UPDATE football.pilkarz SET mecze_zawieszenia = pilkarz.mecze_zawieszenia - 1 WHERE football.pilkarz.id_pilkarza = NEW.id_gospodarza;
		ELSIF pilkarz.mecze_zawieszenia = 0 AND pilkarz.czy_czerwona = TRUE THEN
			UPDATE football.pilkarz SET czy_czerwona = FALSE WHERE football.pilkarz.id_pilkarza = NEW.id_gospodarza;
		END IF;
	
	END LOOP;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_mecz AFTER INSERT OR UPDATE ON football.mecz
FOR ROW EXECUTE PROCEDURE decrease_matches_left();



/* Trigger do sprawdzania czy jedna drużyna gra w dwóch meczach */

CREATE OR REPLACE FUNCTION check_matches() RETURNS TRIGGER AS $$
DECLARE
	match RECORD;
BEGIN
	FOR match IN (SELECT * FROM football.mecz WHERE NEW.nr_kolejki = football.mecz.nr_kolejki) LOOP
		IF match.id_goscia = NEW.id_goscia or match.id_gospodarza = NEW.id_gospodarza or match.id_goscia = NEW.id_gospodarza or match.id_gospodarza = NEW.id_goscia THEN
			RAISE EXCEPTION 'Jedna druzyna nie moze grac dwa razy w jednej kolejce!';
			RETURN NULL;
		END IF;
	END LOOP;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sprawdz_mecze BEFORE INSERT OR UPDATE ON football.mecz
FOR ROW EXECUTE PROCEDURE check_matches();



/* Trigger do sprawdzania czy piłkarz dalej ma czerwoną kartkę */

CREATE OR REPLACE FUNCTION check_red_card() RETURNS TRIGGER AS $$
DECLARE
	pilkarz RECORD;
BEGIN
	SELECT * INTO pilkarz FROM football.pilkarz WHERE NEW.id_pilkarza = football.pilkarz.id_pilkarza;
	IF pilkarz.czy_czerwona = TRUE THEN
		RAISE EXCEPTION 'Pilkarz z czerwona kartka nie moze grac w meczu!';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sprawdz_zawodnika BEFORE INSERT OR UPDATE ON football.pilkarz_mecz
FOR ROW EXECUTE PROCEDURE check_red_card();


/* Trigger do sprawdzania czy pilkarz_mecz zostało odpowiednio wypełnione */

CREATE OR REPLACE FUNCTION check_pilkarz_mecz()
RETURNS TRIGGER
AS
$$
DECLARE
	rec RECORD;
BEGIN
	SELECT * INTO rec FROM football.pilkarz_mecz p WHERE NEW.id_meczu = p.id_meczu AND NEW.id_pilkarza = p.id_pilkarza;
	IF rec IS NULL THEN
		RAISE EXCEPTION 'Bramka / asysta / kartka nie moga zostac wprowadzone bez okreslenia piłkarza grajacego w meczu!';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sprawdz_pilkarz_mecz BEFORE INSERT OR UPDATE ON football.bramki
FOR ROW EXECUTE PROCEDURE check_pilkarz_mecz();

CREATE TRIGGER sprawdz_pilkarz_mecz BEFORE INSERT OR UPDATE ON football.asysta
FOR ROW EXECUTE PROCEDURE check_pilkarz_mecz();

CREATE TRIGGER sprawdz_pilkarz_mecz BEFORE INSERT OR UPDATE ON football.kartka
FOR ROW EXECUTE PROCEDURE check_pilkarz_mecz();


/* Trigger do sprawdzania czy zgadzaja sie nr koszulki w druzynie */

CREATE OR REPLACE FUNCTION check_number()
RETURNS TRIGGER
AS
$$
DECLARE
	rec RECORD;
BEGIN
	FOR rec IN (SELECT * FROM football.pilkarz p WHERE NEW.id_druzyny = p.id_druzyny) LOOP
		IF rec.numer_na_koszulce = NEW.numer_na_koszulce THEN
			RAISE EXCEPTION 'Dwaj pilkarze nie moga miec tego samego numeru koszulki w druzynie';
			RETURN NULL;
		END IF;
	END LOOP;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER sprawdz_numer BEFORE INSERT OR UPDATE ON football.pilkarz
FOR ROW EXECUTE PROCEDURE check_number();