require('coffee-script');
require('./lib/process');
var server = require('./lib/server');

var webServer = new server.Server;
webServer.start();
