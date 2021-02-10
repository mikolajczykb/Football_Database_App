const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {

    try {
        var teams;
        const teamQuery = pool.query("SELECT * FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
            if (error) {
                return response.status(400).render('pages/teams', {items: 0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
            } else {
                teams = result.rows;
                return response.status(200).render('pages/teams', {items: teams, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteTeam = (request, response) => {
    const id = request.params.id;

    try {
        const deleteQuery = pool.query('DELETE FROM football.druzyna WHERE id_druzyny = $1', [id], (error, result) => {
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

const addTeam = (request, response) => {
    const { name, address } = request.body;
    console.log(name, address);

    try {
        const addQuery = pool.query('INSERT INTO football.druzyna (nazwa, adres) VALUES ($1, $2)', [name, address], (error, result) => {
            if (error) {
                return response.status(400).render('pages/teams', {items: 0, result: error.message})
            } else {
                var teams;
                const teamQuery = pool.query("SELECT * FROM football.druzyna d ORDER BY d.id_druzyny", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/teams', {items: 0, result: "Wystąpił błąd przy pobieraniu tabeli druzyna"});
                    } else {
                        teams = result.rows;
                    }
                });
                return response.status(200).render('pages/teams', {items: teams,  result: "Udało się dodać drużynę"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}

const updateTeam = (request, response) => {
    const teamId = request.params.id;
    const { empty, name, address } = request.body;
    console.log( teamId, name, address );


    try {
        const updateQuery = pool.query("UPDATE football.druzyna SET nazwa = $2, adres = $3 WHERE id_druzyny = $1", [teamId, name, address], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, teams: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, teams: teams, result: "Udało się zaktualizować zawodnika"});
                //return response.status(200).send({message: "Udało się zaktualizować zawodnika"});
                response.send({stat: 200, message: "Udało się zaktualizować drużynę"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}


module.exports = {
    getTable,
    deleteTeam,
    addTeam,
    updateTeam
}