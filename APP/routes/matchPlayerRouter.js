var express = require('express');
var router = express.Router();

var matchPlayerController = require('../controllers/matchPlayerController');

router.get('/', matchPlayerController.getTable);
router.delete('/:id', matchPlayerController.deleteMatchPlayer);
router.post('/', matchPlayerController.addMatchPlayer);
router.post('/:id', matchPlayerController.updateMatchPlayer);

module.exports = router;