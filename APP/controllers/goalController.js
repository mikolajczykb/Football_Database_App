const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    
    try {
        var players;
        const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
            if (error) {
                return response.status(400).render('pages/goals', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
            } else {
                players = result.rows;
            }
        });
        var goals;
        const GoalQuery = pool.query("SELECT * FROM football.bramki d ORDER BY d.id_bramki", (error, result) => {
            if (error) {
                return response.status(400).render('pages/goals', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli bramek"});
            } else {
                goals = result.rows;
                return response.status(200).render('pages/goals', {items: goals, teams: players, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteGoal = (request, response) => {
    const goalId = request.params.id;
    //const n = str.indexOf("x");
    //const matchId = str.substring(0, n);
    //const playerId = str.substring(n + 1, str.length);

    try {
        const deleteQuery = pool.query('DELETE FROM football.bramki WHERE id_bramki = $1', [goalId], (error, result) => {
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

const addGoal = (request, response) => {
    const { matchId, playerId, minute, isPenalty, isOwnGoal } = request.body;
    console.log(matchId, playerId, minute, isPenalty, isOwnGoal);

    try {
        const addQuery = pool.query('INSERT INTO football.bramki (id_meczu, id_pilkarza, minuta, czy_karny, czy_samoboj) VALUES ($1, $2, $3, $4, $5)', [matchId, playerId, minute, isPenalty, isOwnGoal], (error, result) => {
            if (error) {
                return response.status(400).render('pages/goals', {items: 0, teams: 0, result: error.message})
            } else {
                var players;
                const playerQuery = pool.query("SELECT * FROM football.piłkarz d ORDER BY d.id_pilkarza", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/goals', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
                    } else {
                        players = result.rows;
                    }
                });
                var goals;
                const GoalQuery = pool.query("SELECT * FROM football.bramki d ORDER BY d.id_meczu", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/goals', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy w meczu"});
                    } else {
                        goals = result.rows;
                        //return response.status(200).render('pages/goals', {items: goals, teams: players, result: ""});
                    }
                });
                return response.status(200).render('pages/goals', {items: goals, teams: players, result: "Udało się dodać bramkę"});
            }
        });
    } catch (error) {
        console.log(error);
    }
}

const updateGoal = (request, response) => {
    const goalId = request.params.id;
    //const n = str.indexOf("x");
    //const oldMatchId = str.substring(0, n);
    //const oldPlayerId = str.substring(n + 1, str.length);
    const { empty, minute, isPenalty, isOwnGoal } = request.body;
    console.log( goalId, minute, isPenalty, isOwnGoal );

    try {
        const updateQuery = pool.query("UPDATE football.bramki SET minuta = $2, czy_karny = $3, czy_samoboj = $4 WHERE id_bramki = $1", [goalId, minute, isPenalty, isOwnGoal], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, goals: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, goals: goals, result: "Udało się zaktualizować zawodnika"});
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
    deleteGoal,
    addGoal,
    updateGoal
}