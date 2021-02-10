var express = require('express');
var router = express.Router();

var refereeController = require('../controllers/refereeController');

router.get('/', refereeController.getTable);
router.delete('/:id', refereeController.deleteReferee);
router.post('/', refereeController.addReferee);
router.post('/:id', refereeController.updateReferee);

module.exports = router;