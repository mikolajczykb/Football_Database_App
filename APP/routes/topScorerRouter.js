var express = require('express');
var router = express.Router();

var topScorerController = require('../controllers/topScorerController');

router.get('/', topScorerController.getTable);


module.exports = router;