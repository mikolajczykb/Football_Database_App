const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {

    var matches;
    try {
        const matchQuery = pool.query("SELECT * FROM football.mecz ORDER BY id_meczu", (error, result) => {
            if (error) {
                return response.status(400).render('pages/matches', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli meczów"});
            } else {
                matches = result.rows;
            }
        });

        var teams;
        const teamQuery = pool.query("SELECT d.id_druzyny, d.nazwa FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
            if (error) {
                return response.status(400).render('pages/matches', {items: 0, teams:0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
            } else {
                teams = result.rows;
                return response.status(200).render('pages/matches', {items: matches, teams: result.rows, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }
}

const deleteMatch = (request, response) => {
    const id = request.params.id;

    try {
        const deleteQuery = pool.query('DELETE FROM football.mecz WHERE id_meczu = $1', [id], (error, result) => {
            if (error) {
                //return response.status(400).send({message: "Nie udało się usunąć rekordu"});
                response.send({stat: 400, message: "Nie udało się usunąć rekordu"});
            } else {
                //return response.status(200).send({message: "Usunięto rekord"});
                response.send({stat: 400, message: "Udało się usunąć rekord"});
            }
        });
    } catch (error) {
        console.log(error);
    }
}

const addMatch = (request, response) => {
    const { hostId, guestId, date, matchday } = request.body;
    console.log(hostId, guestId, date, matchday);

    try {
    const addQuery = pool.query('INSERT INTO football.mecz (id_gospodarza, id_goscia, data_meczu, nr_kolejki) VALUES ($1, $2, $3, $4)', [hostId, guestId, date, matchday], (error, result) => {
        if (error) {
            return response.status(400).render('pages/matches', {items: 0, teams: 0, result: error.message})
        } else {
            var matches;
            const matchQuery = pool.query("SELECT * FROM football.mecz ORDER BY id_meczu", (error, result) => {
                if (error) {
                    return response.status(400).render('pages/matches', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli meczów"});
                } else {
                    matches = result.rows;
                }
            });

            var teams;
            const teamQuery = pool.query("SELECT d.id_druzyny, d.nazwa FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
                if (error) {
                    return response.status(400).render('pages/matches', {items: 0, teams:0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
                } else {
                    teams = result.rows;
                }
            });
            return response.status(200).render('pages/matches', {items: matches, teams: teams, result: "Udało się dodać mecz"});
        }
    });
    } catch (error) {
        console.log(error);
    }
}

const updateMatch = (request, response) => {
    const matchId = request.params.id;
    const { empty, date, matchday } = request.body;
    console.log( matchId, date, matchday );

    try {
        const updateQuery = pool.query("UPDATE football.mecz SET data_meczu = $2, nr_kolejki = $3 WHERE id_meczu = $1", [matchId, date, matchday], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, teams: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, teams: teams, result: "Udało się zaktualizować zawodnika"});
                //return response.status(200).send({message: "Udało się zaktualizować zawodnika"});
                response.send({stat: 200, message: "Udało się zaktualizować mecz"});
            }
        });
    } catch(error) {
        console.log(error);
    }
}


module.exports = {
    getTable,
    deleteMatch,
    addMatch,
    updateMatch
}