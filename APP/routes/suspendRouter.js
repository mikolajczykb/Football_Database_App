var express = require('express');
var router = express.Router();

var suspendController = require('../controllers/suspendController');

router.get('/', suspendController.getTable);

module.exports = router;