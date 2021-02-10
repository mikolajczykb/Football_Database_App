require('dotenv').config({ path: '.env' })

const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');

const app = express();
const port = process.env.PORT;
const pool = require("./database.js");
const forms = multer();

app.set('view engine', 'ejs');

app.use(
    bodyParser.urlencoded({
        extended: true
    })
);

app.use(bodyParser.raw());
app.use(bodyParser.json());
app.use(forms.array());
app.use(express.static("general"));

var tableRouter = require('./routes/tableRouter');
var topScorerRouter = require('./routes/topScorerRouter');
var suspendRouter = require('./routes/suspendRouter');
var timetableRouter = require('./routes/timetableRouter');
var playerRouter = require('./routes/playerRouter');
var matchRouter = require('./routes/matchRouter');
var teamRouter = require('./routes/teamRouter');
var refereeRouter = require('./routes/refereeRouter');
var roleRouter = require('./routes/roleRouter');
var matchPlayerRouter = require('./routes/matchPlayerRouter');
var cardRouter = require('./routes/cardRouter');
var goalRouter = require('./routes/goalRouter');
var assistRouter = require('./routes/assistRouter');

//app.get('/', (req, res) => {
//    res.render('pages/index');
//});

app.use('/', tableRouter);
app.use('/topscorers', topScorerRouter);
app.use('/suspended', suspendRouter);
app.use('/timetable', timetableRouter);
app.use('/players', playerRouter);
app.use('/matches', matchRouter);
app.use('/teams', teamRouter);
app.use('/referees', refereeRouter);
app.use('/roles', roleRouter);
app.use('/matchplayers', matchPlayerRouter);
app.use('/goals', goalRouter);
app.use('/assists', assistRouter);
app.use('/cards', cardRouter);







app.use((req, res, next) => {
    res.status(404).send({
        status: 404,
        error: 'Endpoint Not found'
    })
});


app.listen(port, () => {
    console.log(`App is running on port ${port}.`)
});