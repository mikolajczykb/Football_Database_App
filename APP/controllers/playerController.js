const { response } = require('express');
const pool = require('../database');

var player;

const getPlayerData = async () => {

}

const getTable = (request, response) => {

    var player;
    const playerQuery = pool.query("SELECT * FROM football.pilkarz", (error, result) => {
        if (error) {
            return response.status(400).render('pages/players', {players: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli pilkarze"});
        } else {
            player = result.rows;
        }
    });

    var teams;
    const teamQuery = pool.query("SELECT d.id_druzyny, d.nazwa FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
        if (error) {
            return response.status(400).render('pages/players', {players: 0, teams:0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
        } else {
            teams = result.rows;
            return response.status(200).render('pages/players', {players: player, teams: result.rows, result: ""});
        }
    });
}

const deletePlayer = (request, response) => {
    const id = request.params.id;

    const deleteQuery = pool.query('DELETE FROM football.pilkarz WHERE id_pilkarza = $1', [id], (error, result) => {
        if (error) {
            return response.status(400).send("Nie udało się usunąć rekordu");
        } else {
            return response.status(200).send("Usunięto rekord");
        }
    });
}

const addPlayer = (request, response) => {
    const { teamId, shirtNumber, name, surname } = request.body;
    console.log(teamId, shirtNumber, name, surname);

    const addQuery = pool.query('INSERT INTO football.pilkarz (id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES ($1, $2, $3, $4)', [teamId, shirtNumber, name, surname], (error, result) => {
        if (error) {
            return response.status(200).render('pages/players', {players: 0, teams: 0, result: error.message})
        } else {
            var player;
            const playerQuery = pool.query("SELECT * FROM football.pilkarz", (error, result) => {
                if (error) {
                    return response.status(400).render('pages/players', {players: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli pilkarze"});
                } else {
                    player = result.rows;
                }
            });

            var teams;
            const teamQuery = pool.query("SELECT d.id_druzyny, d.nazwa FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
                if (error) {
                    return response.status(400).render('pages/players', {players: 0, teams:0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
                } else {
                    teams = result.rows;
                }
            });
            return response.status(200).render('pages/players', {players: player, teams: teams, result: "Udało się dodać zawodnika"})
        }
    });
}

const updatePlayer = (request, response) => {

}

module.exports = {
    getTable,
    deletePlayer,
    addPlayer,
    updatePlayer
}