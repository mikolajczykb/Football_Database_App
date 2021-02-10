var express = require('express');
var router = express.Router();

var matchController = require('../controllers/matchController');

router.get('/', matchController.getTable);
router.delete('/:id', matchController.deleteMatch);
router.post('/', matchController.addMatch);
router.post('/:id', matchController.updateMatch);

module.exports = router;