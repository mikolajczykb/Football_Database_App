require('dotenv').config({ path: '.env' })

const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = process.env.PORT;
const pool = require("./database.js");

app.set('view engine', 'ejs');

app.use(
    bodyParser.urlencoded({
        extended: true
    })
);

app.use(bodyParser.raw());
app.use(express.static("public"));

var tableRouter = require('./routes/tableRouter');
var topScorerRouter = require('./routes/topScorerRouter');
var suspendRouter = require('./routes/suspendRouter');
var timetableRouter = require('./routes/timetableRouter');

//app.get('/', (req, res) => {
//    res.render('pages/index');
//});

app.use('/', tableRouter);
app.use('/topscorers', topScorerRouter);
app.use('/suspended', suspendRouter);
app.use('/timetable', timetableRouter);

app.use((req, res, next) => {
    res.status(404).send({
        status: 404,
        error: 'Endpoint Not found'
    })
});


app.listen(port, () => {
    console.log(`App is running on port ${port}.`)
});