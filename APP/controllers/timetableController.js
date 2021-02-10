const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    
    try {
        const tableQuery = pool.query("SELECT * FROM football.terminarz", (error, result) => {
            if (error) {
                return response.status(400).render('pages/timetable', {matches: 0, result: "Wystąpił błąd przy pobieraniu tabeli"});
            } else {
                return response.status(200).render('pages/timetable', {matches: result.rows, result: ""});
            }
        });    
    } catch (error) {
        console.log(error);
    }
    
}

module.exports = {
    getTable
}