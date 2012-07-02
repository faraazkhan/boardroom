# [Boardroom](http://boardroom.carbonfive.com/)

Interactive story boarding for distributed teams.

Currently we use Board Room for reflection meetings, but it will soon be useful for:

* Story writing
* Story mapping
* General distributed story boarding

Board Room is built with [Node.js](http://nodejs.org/) and [MongoDB](http://www.mongodb.org/).

## Development

[Project (Pivotal Tracker)](https://www.pivotaltracker.com/projects/540409)

## Install

### OS X

#### Quick

    brew update
    brew install mongodb
    brew install node
    curl http://npmjs.org/install.sh | sh
    npm install
    # start mongo. for instructions: brew info mongodb
    node server.js

Visit [localhost:7777](http://localhost:7777).

#### With Details

1. Make sure you have the latest [Homebrew](http://mxcl.github.com/homebrew/) and formulae:  
   `brew update`
1. Install [MongoDB](http://www.mongodb.org/) with Homebrew:  
   `brew install mongodb`
1. Follow homebrew's instructions to run Mongo. They're printed after installation; view them again with `brew info mongodb`.
1. Install [Node.js](http://nodejs.org/) with Homebrew:  
   `brew install node`
1. Install the Node package manager [npm](http://npmjs.org/):  
   `curl http://npmjs.org/install.sh | sh`
1. Install project dependencies using npm:  
   `npm install`
1. Run Boardroom:  
   `node server.js`
1. Visit [localhost:7777](http://localhost:7777).

### Ubuntu / Debian
Coming soon
