var express = require('express');
var router = express.Router();

var timetableController = require('../controllers/timetableController');

router.get('/', timetableController.getTable);

module.exports = router;