const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    
    try {
        var players;
        const playerQuery = pool.query("SELECT * FROM football.pilkarz ORDER BY id_pilkarza", (error, result) => {
            if (error) {
                return response.status(400).render('pages/cards', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
            } else {
                players = result.rows;
            }
        });
        var cards;
        const CardQuery = pool.query("SELECT * FROM football.kartka d ORDER BY d.id_kartki", (error, result) => {
            if (error) {
                return response.status(400).render('pages/cards', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli kartek"});
            } else {
                cards = result.rows;
                return response.status(200).render('pages/cards', {items: cards, teams: players, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteCard = (request, response) => {
    const cardId = request.params.id;
    //const n = str.indexOf("x");
    //const matchId = str.substring(0, n);
    //const playerId = str.substring(n + 1, str.length);
    try {
        const deleteQuery = pool.query('DELETE FROM football.kartka WHERE id_kartki = $1', [cardId], (error, result) => {
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

const addCard = (request, response) => {
    const { matchId, playerId, minute, isYellowCard, isRedCard } = request.body;
    console.log(matchId, playerId, minute, isYellowCard, isRedCard);

    try {
        const addQuery = pool.query('INSERT INTO football.kartka (id_meczu, id_pilkarza, minuta, czy_zolta, czy_czerwona) VALUES ($1, $2, $3, $4, $5)', [matchId, playerId, minute, isYellowCard, isRedCard], (error, result) => {
            if (error) {
                return response.status(400).render('pages/cards', {items: 0, teams: 0, result: error.message})
            } else {
                var players;
                const playerQuery = pool.query("SELECT * FROM football.piłkarz d ORDER BY d.id_pilkarza", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/cards', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli piłkarzy"});
                    } else {
                        players = result.rows;
                    }
                });
                var cards;
                const CardQuery = pool.query("SELECT * FROM football.kartka d ORDER BY d.id_kartki", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/cards', {items: 0, teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli kartek"});
                    } else {
                        cards = result.rows;
                        //return response.status(200).render('pages/cards', {items: cards, teams: players, result: ""});
                    }
                });
                return response.status(200).render('pages/cards', {items: cards, teams: players, result: "Udało się dodać kartkę"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}

const updateCard = (request, response) => {
    const cardId = request.params.id;
    //const n = str.indexOf("x");
    //const oldMatchId = str.substring(0, n);
    //const oldPlayerId = str.substring(n + 1, str.length);
    const { empty, minute, isYellowCard, isRedCard } = request.body;
    console.log( cardId, minute, isYellowCard, isRedCard );

    try {
        const updateQuery = pool.query("UPDATE football.kartka SET minuta = $2, czy_zolta = $3, czy_czerwona = $4 WHERE id_kartki = $1", [cardId, minute, isYellowCard, isRedCard], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, cards: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, cards: cards, result: "Udało się zaktualizować zawodnika"});
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
    deleteCard,
    addCard,
    updateCard
}