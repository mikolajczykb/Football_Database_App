
/* Trigger do aktualizowania przy kartkach */

CREATE OR REPLACE FUNCTION kartka_trigger() RETURNS TRIGGER AS $$
DECLARE
	rec RECORD;
	pilkarz_dane RECORD;
	kartka_dane RECORD;
	counter INTEGER;
BEGIN

	/* Sprawdzenie czy poprawne dane zostały wprowadzone */
	IF (NEW.czy_czerwona = FALSE and NEW.czy_zolta = FALSE) OR NEW.czy_czerwona = TRUE AND NEW.czy_zolta = TRUE THEN
			RAISE EXCEPTION 'Kartka musi byc zolta lub czerwona!';
			RETURN NULL;
	END IF;



	SELECT * INTO pilkarz_dane FROM football.pilkarz_mecz WHERE NEW.id_meczu =
	football.pilkarz_mecz.id_meczu AND NEW.id_pilkarza = football.pilkarz_mecz.id_pilkarza;

	IF NEW.minuta NOT BETWEEN pilkarz_dane.poczatek_gry AND pilkarz_dane.koniec_gry THEN
		RAISE EXCEPTION 'Podano zla minute kartki!';
		RETURN NULL;
	END IF;

	/* Sprawdzenie ile piłkarz ma już kartek na koncie */
	SELECT COUNT(*) INTO counter FROM football.kartka WHERE id_meczu = NEW.id_meczu AND id_pilkarza = NEW.id_pilkarza;

	IF counter = 2 THEN
		RAISE EXCEPTION 'Piłkarz nie może otrzymać więcej niż dwie kartki w meczu!';
		RETURN NULL;
	END IF;

	/* Ustawienie ewentualnie czerwonej kartki dla zawodnika */
	SELECT * INTO kartka_dane FROM football.kartka WHERE NEW.id_meczu = football.kartka.id_meczu AND
	NEW.id_pilkarza = football.kartka.id_pilkarza;
	
	IF kartka_dane.czy_czerwona = TRUE THEN
		RAISE EXCEPTION 'Pilkarz nie moze otrzymac dwoch czerwonych kartek!';
		RETURN NULL;
	ELSIF kartka_dane.czy_zolta = TRUE THEN
		DELETE FROM football.asysta WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza AND minuta > NEW.minuta;
		DELETE FROM football.bramki WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza AND minuta > NEW.minuta;
		UPDATE football.pilkarz_mecz SET koniec_gry = NEW.minuta WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza;
		UPDATE football.pilkarz SET czy_czerwona = TRUE, mecze_zawieszenia = 1
		WHERE football.pilkarz.id_pilkarza = NEW.id_pilkarza;
	ELSE
		/* Ustawienie danych w przypadku otrzymania przez piłkarza czerwonej kartki */
		IF NEW.czy_czerwona = TRUE THEN
			DELETE FROM football.asysta WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza AND minuta > NEW.minuta;
			DELETE FROM football.bramki WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza AND minuta > NEW.minuta;
			UPDATE football.pilkarz_mecz SET koniec_gry = NEW.minuta WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza;
			UPDATE football.pilkarz SET czy_czerwona = TRUE, mecze_zawieszenia = 3
			WHERE football.pilkarz.id_pilkarza = NEW.id_pilkarza;
		END IF;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS trigger_kartka ON football.kartka;	
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

DROP TRIGGER IF EXISTS trigger_punkty1 ON football.mecz;
CREATE TRIGGER trigger_punkty1 AFTER INSERT ON football.mecz
FOR ROW EXECUTE PROCEDURE add_points();


CREATE OR REPLACE FUNCTION remove_points() RETURNS TRIGGER AS 
$$
DECLARE
	goscie RECORD;
	gospodarze RECORD;
BEGIN
	SELECT * INTO goscie FROM football.druzyna WHERE OLD.id_goscia = football.druzyna.id_druzyny;
	SELECT * INTO gospodarze FROM football.druzyna WHERE OLD.id_gospodarza = football.druzyna.id_druzyny;
	IF OLD.wynik_gospodarze > OLD.wynik_goscie THEN
		UPDATE football.druzyna SET liczba_punktow = gospodarze.liczba_punktow - 3, wygrane = gospodarze.wygrane - 1 WHERE OLD.id_gospodarza = football.druzyna.id_druzyny;
		UPDATE football.druzyna SET przegrane = goscie.przegrane - 1 WHERE OLD.id_goscia = football.druzyna.id_druzyny;
	ELSIF OLD.wynik_goscie = OLD.wynik_gospodarze THEN
		UPDATE football.druzyna SET liczba_punktow = gospodarze.liczba_punktow - 1, remisy = gospodarze.remisy - 1 WHERE OLD.id_gospodarza = football.druzyna.id_druzyny;
		UPDATE football.druzyna SET liczba_punktow = goscie.liczba_punktow - 1, remisy = goscie.remisy - 1 WHERE OLD.id_goscia = football.druzyna.id_druzyny;
	ELSE
		UPDATE football.druzyna SET liczba_punktow = goscie.liczba_punktow - 3, wygrane = goscie.wygrane - 1 WHERE OLD.id_goscia = football.druzyna.id_druzyny;
		UPDATE football.druzyna SET przegrane = gospodarze.przegrane - 1 WHERE OLD.id_gospodarza = football.druzyna.id_druzyny;
	END IF;

RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS trigger_punkty3 ON football.mecz;
CREATE TRIGGER trigger_punkty3 AFTER DELETE ON football.mecz
FOR ROW EXECUTE PROCEDURE remove_points();




/* Trigger do aktualizowania meczów zawieszenia piłkarzy */

CREATE OR REPLACE FUNCTION decrease_matches_left() RETURNS TRIGGER AS $$
DECLARE
	pilk RECORD;
BEGIN
	FOR pilk IN (SELECT * FROM football.pilkarz WHERE football.pilkarz.id_druzyny = NEW.id_goscia) LOOP
		IF pilk.mecze_zawieszenia > 0 THEN
			UPDATE football.pilkarz SET mecze_zawieszenia = mecze_zawieszenia - 1 WHERE pilk.id_pilkarza = id_pilkarza;
		ELSIF pilk.mecze_zawieszenia = 0 AND pilk.czy_czerwona = TRUE THEN
			UPDATE football.pilkarz SET czy_czerwona = FALSE WHERE football.pilkarz.id_pilkarza = pilk.id_pilkarza;
		END IF;
	END LOOP;
	FOR pilk IN (SELECT * FROM football.pilkarz WHERE football.pilkarz.id_druzyny = NEW.id_gospodarza) LOOP
		IF pilk.mecze_zawieszenia > 0 THEN
			UPDATE football.pilkarz SET mecze_zawieszenia = mecze_zawieszenia - 1 WHERE football.pilkarz.id_pilkarza = pilk.id_pilkarza;
		ELSIF pilk.mecze_zawieszenia = 0 AND pilk.czy_czerwona = TRUE THEN
			UPDATE football.pilkarz SET czy_czerwona = FALSE WHERE football.pilkarz.id_pilkarza = pilk.id_pilkarza;
		END IF;
	
	END LOOP;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS trigger_mecz ON football.mecz;
CREATE TRIGGER trigger_mecz AFTER INSERT ON football.mecz
FOR ROW EXECUTE PROCEDURE decrease_matches_left();



/* Trigger do sprawdzania czy jedna drużyna gra w dwóch meczach */

CREATE OR REPLACE FUNCTION check_matches() RETURNS TRIGGER AS $$
DECLARE
	match RECORD;
BEGIN
	IF NEW.id_goscia = NEW.id_gospodarza THEN
		RAISE EXCEPTION 'Id gościa nie może byc rowne id gospodarza';
		RETURN NULL;
	END IF;

	FOR match IN (SELECT * FROM football.mecz WHERE NEW.nr_kolejki = football.mecz.nr_kolejki) LOOP
		IF NEW.id_meczu != match.id_meczu THEN
			IF match.id_goscia = NEW.id_goscia or match.id_gospodarza = NEW.id_gospodarza or match.id_goscia = NEW.id_gospodarza or match.id_gospodarza = NEW.id_goscia THEN
				RAISE EXCEPTION 'Dwie te same drużyny nie moga grac w jednej kolejce!';
				RETURN NULL;
			END IF;
		END IF;
	END LOOP;

    SELECT * INTO match FROM football.mecz WHERE NEW.id_goscia = id_goscia AND NEW.id_gospodarza = id_gospodarza;
    IF match IS NOT NULL AND TG_OP = 'INSERT' THEN
		RAISE EXCEPTION 'Podczas sezonu ligowego dwie drużyny nie mogą rozegrać tego samego meczu. Zamień gospodarza z gościem';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_mecze ON football.mecz;
CREATE TRIGGER sprawdz_mecze BEFORE INSERT OR UPDATE ON football.mecz
FOR ROW EXECUTE PROCEDURE check_matches();



/* Trigger do sprawdzania czy piłkarz dalej ma czerwoną kartkę */

CREATE OR REPLACE FUNCTION check_matchplayer_insertion() RETURNS TRIGGER AS $$
DECLARE
	pilkarz RECORD;
	mecz RECORD;
	counter INTEGER;
	rec RECORD;
BEGIN
	SELECT * INTO pilkarz FROM football.pilkarz WHERE NEW.id_pilkarza = football.pilkarz.id_pilkarza;
	SELECT * INTO mecz FROM football.mecz WHERE NEW.id_meczu = football.mecz.id_meczu;
	IF pilkarz.czy_czerwona = TRUE THEN
		RAISE EXCEPTION 'Pilkarz z czerwona kartka nie moze grac w meczu!';
		RETURN NULL;
	END IF;
	IF pilkarz.id_druzyny != mecz.id_goscia AND pilkarz.id_druzyny != mecz.id_gospodarza THEN
		RAISE EXCEPTION 'Pilkarz ten nie nalezy do zadnej z grajacych w tym meczu druzyn';
		RETURN NULL;
	END IF;	
	SELECT COUNT(*) INTO counter FROM football.pilkarz p JOIN football.pilkarz_mecz m ON (m.id_pilkarza = p.id_pilkarza) WHERE czy_zmiennik = 'true';
	IF counter > 3 AND NEW.czy_zmiennik = TRUE THEN
		RAISE EXCEPTION 'Nie można przeprowadzić więcej niż 3 zmiany podczas meczu';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_zawodnika ON football.pilkarz_mecz;
CREATE TRIGGER sprawdz_zawodnika BEFORE INSERT OR UPDATE ON football.pilkarz_mecz
FOR ROW EXECUTE PROCEDURE check_matchplayer_insertion();


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
		RAISE EXCEPTION 'Bramka / asysta / kartka nie moga zostac wprowadzone bez okreslenia pilkarza grajacego w meczu!';
		RETURN NULL;
	ELSIF NEW.minuta < rec.poczatek_gry OR NEW.minuta > rec.koniec_gry THEN
		RAISE EXCEPTION 'Podano zla minute!';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_pilkarz_mecz ON football.bramki;
CREATE TRIGGER sprawdz_pilkarz_mecz BEFORE INSERT OR UPDATE ON football.bramki
FOR ROW EXECUTE PROCEDURE check_pilkarz_mecz();

DROP TRIGGER IF EXISTS sprawdz_pilkarz_mecz ON football.asysta;
CREATE TRIGGER sprawdz_pilkarz_mecz BEFORE INSERT OR UPDATE ON football.asysta
FOR ROW EXECUTE PROCEDURE check_pilkarz_mecz();

DROP TRIGGER IF EXISTS sprawdz_pilkarz_mecz ON football.kartka;
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
		IF rec.numer_na_koszulce = NEW.numer_na_koszulce AND rec.id_pilkarza != NEW.id_pilkarza THEN
			RAISE EXCEPTION 'Dwaj pilkarze nie moga miec tego samego numeru koszulki w druzynie';
			RETURN NULL;
		END IF;
	END LOOP;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_numer ON football.pilkarz;
CREATE TRIGGER sprawdz_numer BEFORE INSERT OR UPDATE ON football.pilkarz
FOR ROW EXECUTE PROCEDURE check_number();


CREATE OR REPLACE FUNCTION check_role()
RETURNS TRIGGER
AS
$$
DECLARE
	rec RECORD;
BEGIN
	SELECT * INTO rec FROM football.rola r WHERE r.id_meczu = NEW.id_meczu AND r.id_sedziego = NEW.id_sedziego;
	IF rec IS NOT NULL AND TG_OP = 'INSERT' THEN
		RAISE EXCEPTION 'Jeden sedzia nie może pelnic dwoch rol w jednym meczu!';
	END IF;
	IF NEW.czy_glowny = TRUE THEN
		FOR rec IN (SELECT * FROM football.rola r WHERE NEW.id_meczu = r.id_meczu AND NEW.id_sedziego != r.id_sedziego) LOOP
			IF rec.czy_glowny = TRUE THEN
				RAISE EXCEPTION 'Tylko jeden sedzia podczas meczu może byc glownym';
				RETURN NULL;
			END IF;
		END LOOP;
	END IF;

RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_role on football.rola;
CREATE TRIGGER sprawdz_role BEFORE INSERT OR UPDATE ON football.rola
FOR ROW EXECUTE PROCEDURE check_role();

CREATE OR REPLACE FUNCTION check_goal_data()
RETURNS TRIGGER
AS
$$
BEGIN
	IF NEW.czy_karny = TRUE AND NEW.czy_samoboj = TRUE THEN
		RAISE EXCEPTION 'Bramka nie może być zarówno karnym i samobójem';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_poprawnosc_bramki ON football.bramki;
CREATE TRIGGER sprawdz_poprawnosc_bramki BEFORE INSERT OR UPDATE ON football.bramki
FOR ROW EXECUTE PROCEDURE check_goal_data();


CREATE OR REPLACE FUNCTION check_goal_insert()
RETURNS TRIGGER
AS
$$
DECLARE
	rec RECORD;
	id_druz INTEGER;
	counter INTEGER;
BEGIN
	SELECT COUNT(*) INTO counter FROM football.bramki WHERE NEW.minuta = minuta AND NEW.id_bramki != id_bramki AND NEW.id_meczu = id_meczu;
	IF counter > 0 THEN
		RAISE EXCEPTION 'Nie można strzelić dwóch bramek w jedną minutę! (Piłkarze muszą się nacieszyć po bramce)';
		RETURN NULL;
	END IF;

	SELECT p.id_druzyny INTO id_druz FROM football.pilkarz p WHERE NEW.id_pilkarza = p.id_pilkarza;
	SELECT * INTO rec FROM football.mecz m WHERE NEW.id_meczu = m.id_meczu;
	IF NEW.czy_samoboj = FALSE THEN
		IF id_druz = rec.id_goscia THEN
			UPDATE football.mecz SET wynik_goscie = wynik_goscie + 1 WHERE football.mecz.id_meczu = NEW.id_meczu;
		ELSIF id_druz = rec.id_gospodarza THEN
			UPDATE football.mecz SET wynik_gospodarze = wynik_gospodarze + 1 WHERE football.mecz.id_meczu = NEW.id_meczu;
		END IF;
	ELSE
		IF id_druz = rec.id_goscia THEN
			UPDATE football.mecz SET wynik_gospodarze = wynik_gospodarze + 1 WHERE football.mecz.id_meczu = NEW.id_meczu;
		ELSIF id_druz = rec.id_gospodarza THEN
			UPDATE football.mecz SET wynik_goscie = wynik_goscie + 1 WHERE football.mecz.id_meczu = NEW.id_meczu;
		END IF;
	END IF;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_bramki ON football.bramki;
CREATE TRIGGER sprawdz_bramki AFTER INSERT OR UPDATE ON football.bramki
FOR ROW EXECUTE PROCEDURE check_goal_insert();

CREATE OR REPLACE FUNCTION regulate_goal_delete() RETURNS TRIGGER
AS
$$
DECLARE
	rec RECORD;
	id_druz INTEGER;
BEGIN
	SELECT p.id_druzyny INTO id_druz FROM football.pilkarz p WHERE OLD.id_pilkarza = p.id_pilkarza;
	SELECT * INTO rec FROM football.mecz m WHERE OLD.id_meczu = m.id_meczu;
	IF OLD.czy_samoboj = FALSE THEN
		IF id_druz = rec.id_gospodarza THEN
			UPDATE football.mecz SET wynik_gospodarze = wynik_gospodarze - 1 WHERE OLD.id_meczu = football.mecz.id_meczu;
		ELSIF id_druz = rec.id_goscia THEN
			UPDATE football.mecz SET wynik_goscie = wynik_goscie - 1 WHERE OLD.id_meczu = football.mecz.id_meczu;
		END IF;
	ELSE
		IF id_druz = rec.id_gospodarza THEN
			UPDATE football.mecz SET wynik_goscie = wynik_goscie - 1 WHERE OLD.id_meczu = football.mecz.id_meczu;
		ELSIF id_druz = rec.id_goscia THEN
			UPDATE football.mecz SET wynik_gospodarze = wynik_gospodarze - 1 WHERE OLD.id_meczu = football.mecz.id_meczu;
		END IF;
	END IF;

RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS zmniejsz_bramki ON football.bramki;
CREATE TRIGGER zmniejsz_bramki AFTER UPDATE OR DELETE ON football.bramki
FOR ROW EXECUTE PROCEDURE regulate_goal_delete();


CREATE OR REPLACE FUNCTION check_assist_time() RETURNS TRIGGER
AS
$$
DECLARE
	rec RECORD;
	pilk1 RECORD;
	pilk2 RECORD;
	id_druz INTEGER;
BEGIN
	SELECT * INTO rec FROM football.asysta WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza AND NEW.minuta = minuta;
	IF rec IS NOT NULL THEN
		RAISE EXCEPTION 'Jedna bramka nie może mieć dwóch asyst';
		RETURN NULL;
	END IF;

	SELECT * INTO pilk1 FROM football.pilkarz WHERE id_pilkarza = NEW.id_pilkarza;
	SELECT * INTO pilk2 FROM football.pilkarz WHERE id_pilkarza = (SELECT id_pilkarza FROM football.bramki WHERE NEW.minuta = minuta);
	IF pilk2 IS NULL THEN
		RAISE EXCEPTION 'Podano złą minutę bramki!';
		RETURN NULL;
	ELSIF pilk1.id_pilkarza = pilk2.id_pilkarza THEN
		RAISE EXCEPTION 'Piłkarz nie może sam sobie asystować';
		RETURN NULL;
	END IF;

RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS sprawdz_asyste ON football.asysta;
CREATE TRIGGER sprawdz_asyste BEFORE INSERT OR UPDATE ON football.asysta
FOR ROW EXECUTE PROCEDURE check_assist_time();


CREATE OR REPLACE FUNCTION change_assist_time() RETURNS TRIGGER
AS 
$$
BEGIN
	IF TG_OP = 'UPDATE' THEN
		UPDATE football.asysta SET minuta = NEW.minuta WHERE NEW.id_meczu = id_meczu AND NEW.id_pilkarza = id_pilkarza AND NEW.minuta = minuta;
	ELSIF TG_OP = 'DELETE' THEN
		DELETE FROM football.asysta WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza AND OLD.minuta = minuta;
	END IF;

RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS zmien_czas ON football.bramki;
CREATE TRIGGER zmien_czas AFTER UPDATE OR DELETE ON football.bramki
FOR ROW EXECUTE PROCEDURE change_assist_time();

CREATE OR REPLACE FUNCTION delete_matchplayer_data() RETURNS TRIGGER
AS
$$
BEGIN
	IF TG_OP = 'DELETE' THEN
		DELETE FROM football.bramki WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza;
		DELETE FROM football.asysta WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza;
		DELETE FROM football.kartka WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza;
	ELSIF TG_OP = 'UPDATE' THEN
		DELETE FROM football.bramki WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza AND (minuta > NEW.koniec_gry OR minuta < NEW.poczatek_gry);
		DELETE FROM football.asysta WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza AND (minuta > NEW.koniec_gry OR minuta < NEW.poczatek_gry);
		DELETE FROM football.kartka WHERE OLD.id_meczu = id_meczu AND OLD.id_pilkarza = id_pilkarza AND (minuta > NEW.koniec_gry OR minuta < NEW.poczatek_gry);
	END IF;

RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS usun_pilkarz_mecz_dane ON football.pilkarz_mecz;
CREATE TRIGGER usun_pilkarz_mecz_dane AFTER UPDATE OR DELETE ON football.pilkarz_mecz
FOR ROW EXECUTE PROCEDURE delete_matchplayer_data();

CREATE OR REPLACE FUNCTION get_main_referee(id INTEGER) RETURNS TEXT
AS
$$
DECLARE
	rec RECORD;
BEGIN
	SELECT * INTO rec FROM football.sedzia s JOIN football.rola r ON (s.id_sedziego = r.id_sedziego) WHERE id_meczu = id AND czy_glowny = TRUE;
	IF rec IS NOT NULL THEN
		RETURN concat(rec.imie, ' ', rec.nazwisko);
	ELSE
		RETURN '';
	END IF;
RETURN '';
END;
$$
LANGUAGE 'plpgsql';
	
