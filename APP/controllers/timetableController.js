const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    const tableQuery = pool.query("SELECT * FROM football.terminarz", (error, result) => {
        if (error) {
            return response.status(400).render('pages/timetable', {matches: 0, result: "Wystąpił błąd przy pobieraniu tabeli"});
        } else {
            return response.status(200).render('pages/timetable', {matches: result.rows, result: ""});
        }
    });
}

module.exports = {
    getTable
}