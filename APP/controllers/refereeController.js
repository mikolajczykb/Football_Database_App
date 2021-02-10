const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {

    try {
        var referees;
        const RefereeQuery = pool.query("SELECT * FROM football.sedzia d ORDER BY d.id_sedziego", (error, result) => {
            if (error) {
                return response.status(400).render('pages/referees', {items: 0, result: "Wystąpił błąd przy pobieraniu tabeli sedzia"});
            } else {
                referees = result.rows;
                return response.status(200).render('pages/referees', {items: referees, result: ""});
            }
        });
    } catch (error) {
        console.log(error);
    }

}

const deleteReferee = (request, response) => {
    const id = request.params.id;
    
    try {
        const deleteQuery = pool.query('DELETE FROM football.sedzia WHERE id_sedziego = $1', [id], (error, result) => {
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

const addReferee = (request, response) => {
    const { name, surname, birthDate } = request.body;
    console.log(name, surname, birthDate);

    try {
        const addQuery = pool.query('INSERT INTO football.sedzia (imie, nazwisko, data_urodzenia) VALUES ($1, $2, $3)', [name, surname, birthDate], (error, result) => {
            if (error) {
                return response.status(400).render('pages/referees', {items: 0, result: error.message})
            } else {
                var referees;
                const RefereeQuery = pool.query("SELECT * FROM football.sedzia d ORDER BY d.id_sedziego", (error, result) => {
                    if (error) {
                        return response.status(400).render('pages/referees', {items: 0, result: "Wystąpił błąd przy pobieraniu tabeli sedzia"});
                    } else {
                        referees = result.rows;
                    }
                });
                return response.status(200).render('pages/referees', {items: referees,  result: "Udało się dodać sędziego"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}

const updateReferee = (request, response) => {
    const RefereeId = request.params.id;
    const { empty, name, surname, birthDate } = request.body;
    console.log( RefereeId, name, surname, birthDate );

    try {
        const updateQuery = pool.query("UPDATE football.sedzia SET imie = $2, nazwisko = $3, data_urodzenia = $4 WHERE id_sedziego = $1", [RefereeId, name, surname, birthDate], (error, result) => {
            if (error) {
                //return response.status(400).render('pages/matches', {matches: 0, referees: 0, result: error.message})
                //return response.status(400).send({message: error.message});
                var message = error.message;
                response.send({stat: 400, message: message});
                return;
            } else {
                //return response.status(200).render('pages/matches', {matches: player, referees: referees, result: "Udało się zaktualizować zawodnika"});
                //return response.status(200).send({message: "Udało się zaktualizować zawodnika"});
                response.send({stat: 200, message: "Udało się zaktualizować sędziego"});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}


module.exports = {
    getTable,
    deleteReferee,
    addReferee,
    updateReferee
}