var express = require('express');
var router = express.Router();

var roleController = require('../controllers/roleController');

router.get('/', roleController.getTable);
router.delete('/:id', roleController.deleteRole);
router.post('/', roleController.addRole);
router.post('/:id', roleController.updateRole);

module.exports = router;