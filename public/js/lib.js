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
