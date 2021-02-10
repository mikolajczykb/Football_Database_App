var express = require('express');
var router = express.Router();

var teamController = require('../controllers/teamController');

router.get('/', teamController.getTable);
router.delete('/:id', teamController.deleteTeam);
router.post('/', teamController.addTeam);
router.post('/:id', teamController.updateTeam);

module.exports = router;