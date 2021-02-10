const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {

    var player;
    try {
        const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
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
    } catch (error) {
        console.log(error);
    }
}

const deletePlayer = (request, response) => {
    const id = request.params.id;
    try {
        const deleteQuery = pool.query('DELETE FROM football.pilkarz WHERE id_pilkarza = $1', [id], (error, result) => {
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

const addPlayer = (request, response) => {
    const { teamId, shirtNumber, name, surname } = request.body;
    console.log(teamId, shirtNumber, name, surname);

    try {
        const addQuery = pool.query('INSERT INTO football.pilkarz (id_druzyny, numer_na_koszulce, imie, nazwisko) VALUES ($1, $2, $3, $4)', [teamId, shirtNumber, name, surname], (error, result) => {
            if (error) {
                return response.status(400).render('pages/players', {players: 0, teams: 0, result: error.message})
            } else {
                var player;
                const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
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
                return response.status(200).render('pages/players', {players: player, teams: teams, result: "Udało się dodać zawodnika"});
            }
        });        
    } catch (error) {
        console.log(error);
    }

}

const updatePlayer = (request, response) => {
    const playerId = request.params.id;
    //const { shirtNumber, name, surname } = request.body;
    const shirtNumber = request.body.shirtNumber;
    const name = request.body.name;
    const surname = request.body.surname;
    console.log( playerId, shirtNumber, name, surname);


    try {
        const updatePlayer = pool.query("UPDATE football.pilkarz SET numer_na_koszulce = $2, imie = $3, nazwisko = $4 WHERE id_pilkarza = $1", [playerId, shirtNumber, name, surname], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/players', {players: 0, teams: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                /*var player;
                const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
                    if (error) {
                        //return response.status(400).render('pages/players', {players: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli pilkarze"});
                        //return response.status(400).send({message: error.message});
                        response.send({stat: 400, message: error.message});
                        return;
                    } else {
                        player = result.rows;
                    }
                });
    
                var teams;
                const teamQuery = pool.query("SELECT d.id_druzyny, d.nazwa FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
                    if (error) {
                        //return response.status(400).render('pages/players', {players: 0, teams:0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
                        //return response.status(400).send({message: error.message});
                        response.send({stat: 400, message: error.message});
                        return;
                    } else {
                        teams = result.rows;
                    }
                });
                //return response.status(200).render('pages/players', {players: player, teams: teams, result: "Udało się zaktualizować zawodnika"});
                ///return response.status(200).send({message: "Udało się zaktualizować zawodnika"});*/
                response.send({stat: 200, message: "Udało się zaktualizować zawodnika"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}

module.exports = {
    getTable,
    deletePlayer,
    addPlayer,
    updatePlayer
}