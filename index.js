require('coffee-script');
var routes = require('./lib/routes'),
  router = new routes.Router;

router.start();
