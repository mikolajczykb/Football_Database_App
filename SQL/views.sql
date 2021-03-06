DROP VIEW IF EXISTS football.tabela;
CREATE VIEW football.tabela AS SELECT ROW_NUMBER() OVER(ORDER BY druzyna.liczba_punktow DESC, druzyna.nazwa) AS pozycja, druzyna.nazwa as nazwa, druzyna.wygrane + druzyna.remisy + druzyna.przegrane AS rozegrano,
	druzyna.wygrane as wygrane, druzyna.remisy as remisy, druzyna.przegrane as przegrane, druzyna.liczba_punktow AS punkty,
	(SELECT COUNT(*) FROM football.pilkarz p WHERE druzyna.id_druzyny = p.id_druzyny) AS ilosc_pilkarzy
	FROM football.druzyna druzyna GROUP BY druzyna.id_druzyny, druzyna.nazwa, druzyna.wygrane, druzyna.remisy, druzyna.przegrane, druzyna.liczba_punktow
	ORDER BY pozycja;

DROP VIEW IF EXISTS football.top_scorers;
CREATE VIEW football.top_scorers AS SELECT RANK() OVER(ORDER BY (SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza) DESC) AS pozycja, pilkarz.imie, pilkarz.nazwisko, 
    (SELECT d.nazwa FROM football.druzyna d WHERE d.id_druzyny = pilkarz.id_druzyny),
	(SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza AND b.czy_samoboj = FALSE) AS gole,
	(SELECT COUNT(*) FROM football.asysta a WHERE pilkarz.id_pilkarza = a.id_pilkarza) AS asysty,
	(SELECT COUNT(*) FROM football.kartka k WHERE pilkarz.id_pilkarza = k.id_pilkarza) AS kartki ,
	(SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza AND b.czy_karny = TRUE) AS karne
	FROM football.pilkarz pilkarz
	GROUP BY pilkarz.id_pilkarza, pilkarz.imie, pilkarz.nazwisko
	HAVING (SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza AND b.czy_samoboj = FALSE) >= 1
	ORDER BY pozycja;

DROP VIEW IF EXISTS football.terminarz;
CREATE VIEW football.terminarz AS SELECT mecz.nr_kolejki, mecz.data_meczu, (SELECT nazwa FROM football.druzyna d WHERE d.id_druzyny = mecz.id_gospodarza) as gospodarz,
    (SELECT nazwa FROM football.druzyna d1 WHERE d1.id_druzyny = mecz.id_goscia) as gosc, 
	mecz.wynik_gospodarze,
    mecz.wynik_goscie,
	get_main_referee(mecz.id_meczu) as glowny_sedzia
	 FROM football.mecz mecz ORDER BY mecz.nr_kolejki, mecz.data_meczu;

DROP VIEW IF EXISTS football.zawieszenia;
CREATE VIEW football.zawieszenia AS SELECT (SELECT d.nazwa FROM football.druzyna d WHERE d.id_druzyny = pilkarz.id_druzyny) AS druzyna, pilkarz.imie, pilkarz.nazwisko,
    CASE
        WHEN pilkarz.mecze_zawieszenia > 0 THEN CAST(pilkarz.mecze_zawieszenia AS TEXT)
        WHEN pilkarz.mecze_zawieszenia = 0 THEN 'Niedostepny do wpisania w polu piłkarz_mecz, koniec zawieszenia'
        END mecze_zawieszenia
    FROM football.pilkarz pilkarz WHERE pilkarz.czy_czerwona = TRUE;