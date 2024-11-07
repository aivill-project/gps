const express = require('express');
const router = express.Router();
const indexController = require('../controllers/index.controller');

router.get('/', indexController.getHome);

router.get('/maps-config', (req, res) => {
  res.json({
    apiKey: process.env.GOOGLE_MAPS_API_KEY
  });
});

module.exports = router;