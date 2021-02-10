const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    
    try {
        var players;
        const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
            if (error) {
                return response.status(400).render('pages/assists', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
            } else {
                players = result.rows;
            }
        });
        var assists;
        const AssistQuery = pool.query("SELECT * FROM football.asysta d ORDER BY d.id_meczu", (error, result) => {
            if (error) {
                return response.status(400).render('pages/assists', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli asyst"});
            } else {
                assists = result.rows;
                return response.status(200).render('pages/assists', {items: assists, teams: players, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteAssist = (request, response) => {
    const assistId = request.params.id;
    //const n = str.indexOf("x");
    //const matchId = str.substring(0, n);
    //const playerId = str.substring(n + 1, str.length);

    try {
        const deleteQuery = pool.query('DELETE FROM football.asysta WHERE id_asysty = $1', [assistId], (error, result) => {
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

const addAssist = (request, response) => {
    const { matchId, playerId, minute } = request.body;
    console.log(matchId, playerId, minute);

    try {
        const addQuery = pool.query('INSERT INTO football.asysta (id_meczu, id_pilkarza, minuta) VALUES ($1, $2, $3)', [matchId, playerId, minute], (error, result) => {
            if (error) {
                return response.status(400).render('pages/assists', {items: 0, teams: 0, result: error.message})
            } else {
                var players;
                const playerQuery = pool.query("SELECT * FROM football.piłkarz d ORDER BY d.id_pilkarza", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/assists', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
                    } else {
                        players = result.rows;
                    }
                });
                var assists;
                const AssistQuery = pool.query("SELECT * FROM football.asysta d ORDER BY d.id_meczu", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/assists', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy w meczu"});
                    } else {
                        assists = result.rows;
                        //return response.status(200).render('pages/assists', {items: assists, teams: players, result: ""});
                    }
                });
                return response.status(200).render('pages/assists', {items: assists, teams: players, result: "Udało się dodać bramkę"});
            }
        });
    } catch (error) {
        console.log(error);
    }
}

const updateAssist = (request, response) => {
    const assistId = request.params.id;
    //const n = str.indexOf("x");
    //const oldMatchId = str.substring(0, n);
    //const oldPlayerId = str.substring(n + 1, str.length);
    const { empty, minute } = request.body;
    console.log( assistId, minute );

    try {
        const updateQuery = pool.query("UPDATE football.asysta SET minuta = $2 WHERE id_asysty = $1", [assistId, minute], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, assists: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, assists: assists, result: "Udało się zaktualizować zawodnika"});
                //return response.status(200).send({message: "Udało się zaktualizować zawodnika"});
                response.send({stat: 200, message: "Udało się zaktualizować rekord"});
            }
        });
    } catch (error) {
        console.log(error);
    }
}


module.exports = {
    getTable,
    deleteAssist,
    addAssist,
    updateAssist
}