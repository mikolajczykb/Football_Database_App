var express = require('express');
var router = express.Router();

var goalController = require('../controllers/goalController');

router.get('/', goalController.getTable);
router.delete('/:id', goalController.deleteGoal);
router.post('/', goalController.addGoal);
router.post('/:id', goalController.updateGoal);

module.exports = router;