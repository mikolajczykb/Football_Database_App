var express = require('express');
var router = express.Router();

var assistController = require('../controllers/assistController');

router.get('/', assistController.getTable);
router.delete('/:id', assistController.deleteAssist);
router.post('/', assistController.addAssist);
router.post('/:id', assistController.updateAssist);

module.exports = router;