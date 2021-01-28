var express = require('express');
var router = express.Router();

var tableController = require('../controllers/tableController');

router.get('/', tableController.getTable);


module.exports = router;