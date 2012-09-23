require('coffee-script');

var Migrator = require('./lib/migrator'),
  migrator = new Migrator;

migrator.migrate();

var Router = require('./lib/router'),
  router = new Router;

router.start();
