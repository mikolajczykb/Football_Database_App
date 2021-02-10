const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    
    try {
        var players;
        const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
            if (error) {
                return response.status(400).render('pages/matchplayers', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
            } else {
                players = result.rows;
            }
        });
        var matchplayers;
        const matchPlayerQuery = pool.query("SELECT * FROM football.pilkarz_mecz d ORDER BY d.id_meczu", (error, result) => {
            if (error) {
                return response.status(400).render('pages/matchplayers', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy w meczu"});
            } else {
                matchplayers = result.rows;
                return response.status(200).render('pages/matchplayers', {items: matchplayers, teams: players, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteMatchPlayer = (request, response) => {
    const str = request.params.id;
    const n = str.indexOf("x");
    const matchId = str.substring(0, n);
    const playerId = str.substring(n + 1, str.length);

    try {
        const deleteQuery = pool.query('DELETE FROM football.pilkarz_mecz WHERE id_meczu = $1 AND id_pilkarza = $2', [matchId, playerId], (error, result) => {
            if (error) {
                //return response.status(400).send({message: "Nie udało się usunąć rekordu"});
                response.send({stat: 400, message: "Nie udało się usunąć rekordu"});
            } else {
                //return response.status(200).send({message: "Usunięto rekord"});
                response.send({stat: 400, message: "Udało się usunąć rekord"});
            }
        });
    } catch(error) {
        console.log(error);
    }
}

const addMatchPlayer = (request, response) => {
    const { matchId, playerId, isSub, startGame, endGame } = request.body;
    console.log(matchId, playerId, isSub, startGame, endGame);

    try {
        const addQuery = pool.query('INSERT INTO football.pilkarz_mecz (id_meczu, id_pilkarza, czy_zmiennik, poczatek_gry, koniec_gry) VALUES ($1, $2, $3, $4, $5)', [matchId, playerId, isSub, startGame, endGame], (error, result) => {
            if (error) {
                return response.status(400).render('pages/matchplayers', {items: 0, teams: 0, result: error.message})
            } else {
                var players;
                const playerQuery = pool.query("SELECT * FROM football.piłkarz d ORDER BY d.id_pilkarza", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/matchplayers', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
                    } else {
                        players = result.rows;
                    }
                });
                var matchplayers;
                const matchPlayerQuery = pool.query("SELECT * FROM football.pilkarz_mecz d ORDER BY d.id_meczu", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/matchplayers', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy w meczu"});
                    } else {
                        matchplayers = result.rows;
                        //return response.status(200).render('pages/matchplayers', {items: matchplayers, teams: players, result: ""});
                    }
                });
                return response.status(200).render('pages/matchplayers', {items: matchplayers, teams: players, result: "Udało się dodać piłkarza w meczu"});
            }
        });
    } catch(error) {
        console.log(error);
    }
}

const updateMatchPlayer = (request, response) => {
    const str = request.params.id;
    const n = str.indexOf("x");
    const oldMatchId = str.substring(0, n);
    const oldPlayerId = str.substring(n + 1, str.length);
    const { empty, empty2, isSub, startGame, endGame } = request.body;
    console.log( oldMatchId, oldPlayerId, isSub, startGame, endGame );

    try {
        const updateQuery = pool.query("UPDATE football.pilkarz_mecz SET czy_zmiennik = $3, poczatek_gry = $4, koniec_gry = $5 WHERE id_meczu = $1 AND id_pilkarza = $2", [oldMatchId, oldPlayerId, isSub, startGame, endGame], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, matchplayers: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, matchplayers: matchplayers, result: "Udało się zaktualizować zawodnika"});
                //return response.status(200).send({message: "Udało się zaktualizować zawodnika"});
                response.send({stat: 200, message: "Udało się zaktualizować rekord"});
            }
        });
    } catch(error) {
        console.log(error);
    }
}


module.exports = {
    getTable,
    deleteMatchPlayer,
    addMatchPlayer,
    updateMatchPlayer
}