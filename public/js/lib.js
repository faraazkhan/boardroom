(function( $ ) {
  $.fn.removeClassMatching = function(regexp) {
    this.each(function() {
      var remove = $(this).attr('class').match(regexp)
      if (remove) {
        $(this).removeClass(remove.join(' '));
      }
    });
  };
})( jQuery );

(function( $ ) {
  $.fn.containsPoint = function(x, y) {
    var dx = x - this.offset().left;
    var dy = y - this.offset().top;
    return (dx > 0 && dy > 0 && dx < this.outerWidth() && dy < this.outerHeight());
  };
})( jQuery );
