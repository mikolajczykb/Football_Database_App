var express = require('express');
var router = express.Router();

var cardController = require('../controllers/cardController');

router.get('/', cardController.getTable);
router.delete('/:id', cardController.deleteCard);
router.post('/', cardController.addCard);
router.post('/:id', cardController.updateCard);

module.exports = router;