var express = require('express');
var router = express.Router();

var playerController = require('../controllers/playerController');

router.get('/', playerController.getTable);
router.delete('/:id', playerController.deletePlayer);
router.post('/', playerController.addPlayer);
router.put('/:id', playerController.updatePlayer);

module.exports = router;