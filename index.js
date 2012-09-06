require('coffee-script');
require('./lib/process');
var routes = require('./lib/routes');

var router = new routes.Router;
router.start();
