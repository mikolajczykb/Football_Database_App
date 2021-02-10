const e = require('express');
const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {

    try {
        var referees;
        const RefereeQuery = pool.query("SELECT * FROM football.sedzia d ORDER BY d.id_sedziego", (error, result) => {
            if (error) {
                return response.status(400).render('pages/referees', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli sedzia"});
            } else {
                referees = result.rows;
            }
        });
        var roles;
        const RoleQuery = pool.query("SELECT * FROM football.rola d ORDER BY d.id_meczu", (error, result) => {
            if (error) {
                return response.status(400).render('pages/roles', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli ról"});
            } else {
                roles = result.rows;
                return response.status(200).render('pages/Roles', {items: roles, teams: referees, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteRole = (request, response) => {
    const str = request.params.id;
    const n = str.indexOf("x");
    const matchId = str.substring(0, n);
    const refereeId = str.substring(n + 1, str.length);

    try {
        const deleteQuery = pool.query('DELETE FROM football.rola WHERE id_meczu = $1 AND id_sedziego = $2', [matchId, refereeId], (error, result) => {
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

const addRole = (request, response) => {
    const { matchId, refereeId, isMain } = request.body;
    console.log(matchId, refereeId, isMain);

    try {
        const addQuery = pool.query('INSERT INTO football.rola (id_meczu, id_sedziego, czy_glowny) VALUES ($1, $2, $3)', [matchId, refereeId, isMain], (error, result) => {
            if (error) {
                return response.status(400).render('pages/roles', {items: 0, teams: referees, result: error.message})
            } else {
                var roles;
                const RoleQuery = pool.query("SELECT * FROM football.rola d ORDER BY d.id_druzyny", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/roles', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli rola"});
                    } else {
                        roles = result.rows;
                    }
                });
                var referees;
                const RefereeQuery = pool.query("SELECT * FROM football.sedzia d ORDER BY d.id_sedziego", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/referees', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli sedzia"});
                    } else {
                        referees = result.rows;
                    }
                });
                return response.status(200).render('pages/roles', {items: roles, teams: referees, result: "Udało się dodać rolę"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}

const updateRole = (request, response) => {
    const str = request.params.id;
    const n = str.indexOf("x");
    const oldMatchId = str.substring(0, n);
    const oldRefereeId = str.substring(n + 1, str.length);
    const { empty, empty2, matchId, refereeId, isMain } = request.body;
    console.log( oldMatchId, oldRefereeId, matchId, refereeId, isMain );

    try {
        const updateQuery = pool.query("UPDATE football.rola SET id_meczu = $3, id_sedziego = $4, czy_glowny = $5 WHERE id_meczu = $1 AND id_sedziego = $2", [oldMatchId, oldRefereeId, matchId, refereeId, isMain], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, Roles: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, Roles: Roles, result: "Udało się zaktualizować zawodnika"});
                //return response.status(200).send({message: "Udało się zaktualizować zawodnika"});
                response.send({stat: 200, message: "Udało się zaktualizować rolę"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}


module.exports = {
    getTable,
    deleteRole,
    addRole,
    updateRole
}