# [Board Room](http://boardroom.carbonfive.com/)

Interactive story boarding for distributed teams.

Currently we use Board Room for reflection meetings, but it will soon be useful for:
* Story writing
* Story mapping
* General distributed story boarding

Board Room is built with [Node.js](http://nodejs.org/), [MongoDB](http://www.mongodb.org/), and [Socket.IO](http://socket.io/).

## Development

Product Owners:
- Mike Wynholds
- Christian Nelson (if Mike's unavailable)

[Project (Pivotal Tracker)](https://www.pivotaltracker.com/projects/540409)

### Git Branching Strategy

#### Overview
- Develop on feature branches (named like `features/32195787-delete-a-board`)
- `merge --no-ff` into `development`, and deliver in Tracker
- Once accepted, merge into `master`

### Environment Hosting
- [Acceptance](http://boardroom.carbonfive.com:81/)
- [Production](http://boardroom.carbonfive.com/)

### Testing

- [jasmine-headless-webkit](http://johnbintz.github.com/jasmine-headless-webkit/) (clientside testing)
- [jasmine-node](https://github.com/mhevery/jasmine-node) (serverside testing)
- [Sinon.JS](http://sinonjs.org/) (spies, faking time)
- "cake spec:client", "cake spec:server", "cake spec" are available for running tests

### Deploying

Deployment uses Capistrano. Acceptance is the default stage.

- cap deploy
- cap production deploy

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

## New to Mongo?

Run through the quick tutorial in the "Try It Out" shell at [mongodb.org](http://www.mongodb.org/).

Then:

    $ mongo
    MongoDB shell version: 2.0.4
    connecting to: test
    > help
    ⋮
    > show dbs
    carbonite
    ⋮
    > use carbonite
    switched to db carbonite
    > db.boards.find()
    { "name" : "test", "title" : "test", "_id" : ObjectId("4ff1e6658aa3445a14000001") }
    > db.cards.find()
    ⋮

