var mongo = require('mongodb'),
    BSON = mongo.BSONPure,
    mongoUrl = 'mongodb://localhost/boardroom_' + (process.env['NODE_ENV'] || 'development');

function errorWrapper( handler ) {
  return function( error ) {
    if( error )
      return console.log( "DB ERROR", (error.message ? error.message : error) );

    if ( handler )
      handler.apply(this, Array.prototype.slice.apply( arguments, [1] ) )
  }
}

var database;
mongo.connect( mongoUrl, errorWrapper( function( _database ) {
    database = _database;
  })
);

function withCollection( name, callback ) {
  database.collection( name, errorWrapper( callback ) );
}

exports.saveCard = function( card, callback /* (savedCard) */ ) {
  withCollection( 'cards', function( cards ) {
    card.authors = [];
    cards.save( card, callback ? {safe:true} : {}, errorWrapper(callback) );
  });
}

exports.updateCard = function( card, callback /* (count) */ ) {
  withCollection( 'cards', function( cards ) {
    cards.find( {_id:new BSON.ObjectID(card._id) }, errorWrapper( function( cursor ) {
      cursor.each( errorWrapper( function( existingCard ) {
        if ( existingCard == null ) return;
        if ( card.x ) existingCard.x = card.x;
        if ( card.y ) existingCard.y = card.y;
        if ( card.text ) existingCard.text = card.text;
        if ( card.colorIndex ) existingCard.colorIndex = card.colorIndex;
        if ( card.deleted != null ) existingCard.deleted = card.deleted;
        if ( card.author && (! existingCard.authors || ! (existingCard.authors.indexOf(card.author)>-1)) )
          (existingCard.authors=existingCard.authors||[]).push( card.author );
        cards.save( existingCard, callback ? {safe:true} : {}, errorWrapper(callback) );
      }) );
    }) );
  });
}

exports.updateCardGroup = function( data, callback ) {
  withCollection( 'cards', function( cards ) {
    cards.findOne( {_id:new BSON.ObjectID(data.noteId) }, errorWrapper( function( card ) {
      cards.findOne( {_id:new BSON.ObjectID(data.targetId) }, errorWrapper( function( target ) {
        if (!target.groupId) {
          target.groupId = target._id;
          target.groupIndex = 0;
          cards.save( target );
        }
        card.groupId = target.groupId;
        card.groupIndex = target.groupIndex + 1;
        cards.save( card, callback ? {safe:true} : {}, errorWrapper(callback) );
      }) );
    }) );
  });
};

exports.removeCard = function( card, callback /* (count) */ ) {
  withCollection( 'cards', function( cards ) {
    cards.remove( { _id: new BSON.ObjectID(card._id) }, errorWrapper(callback) );
  } );
}

exports.arrayReducer = function( complete /* (array) */, array /*?*/ ) {
  array = array || [];
  return function( item ) {
    if ( item != null ) return array.push( item );
    if ( complete ) return complete( array );
  }
}

exports.findCards = function( criteria, reducer /* (card | null) */ ) {
  withCollection( 'cards', function( cards ) {
    cards.find( criteria, errorWrapper( function( cursor ) {
      cursor.each( errorWrapper( reducer ) );
    }) );
  });
}

exports.findBoards = function( criteria, reducer ) {
  withCollection( 'boards', function( coll ) {
    coll.find( criteria, errorWrapper( function( cursor ) {
      cursor.each( errorWrapper( reducer ) );
    }) );
  });
}

exports.findBoardCardCounts = function( callback /* (results) */ ) {
  withCollection( 'cards', function( cards ) {
    cards.group( {boardName:true}, {}, { count:0 },
       function(item,stats) { stats.count++;  },
       errorWrapper( callback )
    );
  });
}

exports.findOrCreateBoard = function( boardName, creator_id, callback ) {
  withCollection( 'boards', function( collection ) {
    collection.find( { name: boardName }, { limit: 1 } ).toArray( function(err, objs) {
      if (objs.length === 0) {
        var b = { name: boardName, title: boardName, creator_id: creator_id };
        collection.insert(b);
        callback(b);
      } else {
        callback(objs[0]);
      }
    });
  });
}

exports.findBoard = function( boardName, callback ) {
  withCollection( 'boards', function( collection ) {
    collection.find( { name: boardName }, { limit: 1 } ).toArray( function(err, objs) {
      if (objs.length > 0) {
        callback(objs[0]);
      }
    });
  });
}

exports.updateBoard = function( boardName, attrs, callback ) {
  withCollection( 'boards', function( collection ) {
    collection.update( { name: boardName }, { $set: attrs }, callback ? {safe:true} : {}, errorWrapper(callback) );
  });
}

exports.deleteBoard = function( boardId, callback ) {
  withCollection( 'boards', function( collection ) {
    collection.update( { _id:new BSON.ObjectID(boardId) }, { $set: {'deleted':true} }, callback ? {safe:true} : {}, errorWrapper(callback) );
  });
}

exports.createGroup = function( name, cardIds, callback ) {
  withCollection( 'groups', function( groups ) {
    var group = {name: name, cardIds: cardIds};
    groups.insert(group);
    callback(group);
  });
}

exports.updateGroup = function( _id, cardIds, callback ) {
  withCollection( 'groups', function( groups ) {
    var group = {$set: {cardIds: cardIds}};
    groups.update({ _id: new BSON.ObjectID(_id) }, group);
    if (callback) {
      callback(group);
    }
  });
}