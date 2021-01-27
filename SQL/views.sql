DROP VIEW tabela;
CREATE VIEW tabela AS SELECT ROW_NUMBER() OVER(ORDER BY druzyna.liczba_punktow DESC, druzyna.nazwa) AS pozycja, druzyna.nazwa as nazwa, druzyna.wygrane + druzyna.remisy + druzyna.przegrane AS rozegrano,
	druzyna.wygrane as wygrane, druzyna.remisy as remisy, druzyna.przegrane as przegrane, druzyna.liczba_punktow AS punkty,
	(SELECT COUNT(*) FROM football.pilkarz p WHERE druzyna.id_druzyny = p.id_druzyny) AS ilosc_pilkarzy FROM football.druzyna druzyna GROUP BY druzyna.id_druzyny, druzyna.nazwa, druzyna.wygrane, druzyna.remisy, druzyna.przegrane, druzyna.liczba_punktow
	ORDER BY pozycja;

DROP VIEW top_scorers;
CREATE VIEW top_scorers AS SELECT RANK() OVER(ORDER BY (SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza)) AS pozycja, pilkarz.imie, pilkarz.nazwisko, 
    (SELECT d.nazwa FROM football.druzyna d WHERE d.id_druzyny = pilkarz.id_druzyny),
	(SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza) AS gole,
	(SELECT COUNT(*) FROM football.asysta a WHERE pilkarz.id_pilkarza = a.id_pilkarza) AS asysty,
	(SELECT COUNT(*) FROM football.kartka k WHERE pilkarz.id_pilkarza = k.id_pilkarza) AS kartki
	FROM football.pilkarz pilkarz
	GROUP BY pilkarz.id_pilkarza, pilkarz.imie, pilkarz.nazwisko
	HAVING (SELECT COUNT(*) FROM football.bramki b WHERE pilkarz.id_pilkarza = b.id_pilkarza) >= 1
	ORDER BY pozycja;

DROP VIEW terminarz;
CREATE VIEW terminarz AS SELECT mecz.nr_kolejki, mecz.data_meczu, (SELECT nazwa FROM football.druzyna d WHERE d.id_druzyny = mecz.id_gospodarza) as gospodarz,
    (SELECT nazwa FROM football.druzyna d1 WHERE d1.id_druzyny = mecz.id_goscia) as gosc, mecz.wynik_gospodarze,
    mecz.wynik_goscie FROM football.mecz mecz ORDER BY mecz.nr_kolejki, mecz.data_meczu;

DROP VIEW zawieszenia;
CREATE VIEW zawieszenia AS SELECT (SELECT d.nazwa FROM football.druzyna d WHERE d.id_druzyny = pilkarz.id_druzyny) AS druzyna, pilkarz.imie, pilkarz.nazwisko,
    CASE
        WHEN pilkarz.mecze_zawieszenia > 0 THEN CAST(pilkarz.mecze_zawieszenia AS TEXT)
        WHEN pilkarz.mecze_zawieszenia = 0 THEN 'Niedostępny do wpisania, ostatni mecz zawieszenia'
        END mecze_zawieszenia
    FROM football.pilkarz pilkarz WHERE pilkarz.czy_czerwona = TRUE;