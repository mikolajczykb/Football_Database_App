const { response } = require('express');
const pool = require('../database');

const getTable = (request, response) => {
    const tableQuery = pool.query("SELECT * FROM football.tabela", (error, result) => {
        if (error) {
            return response.status(400).render('pages/index', {teams: 0, result: "Wystąpił błąd przy pobieraniu tabeli"});
        } else {
            return response.status(200).render('pages/index', {teams: result.rows, result: ""});
        }
    });
}

module.exports = {
    getTable
}