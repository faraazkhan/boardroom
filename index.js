require('coffee-script');
var routes = require('./app/server/routes'),
  router = new routes.Router;

router.start();
