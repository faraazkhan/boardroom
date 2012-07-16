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

(function( $ ) {
  $.fn.onMousePause = function(callback, duration) {
    var $this = this;
    var timeout;
    $this.on('mousemove.onMousePause', function(e) {
      clearTimeout(timeout);
      timeout = setTimeout(function() {
        callback.call($this, e);
      }, duration || 400);
    });

    return {
      off: function () {
        clearTimeout(timeout);
        $this.off('.onMousePause')
      }
    }
  };
})( jQuery );

(function( $ ) {
  $.fn.followDrag = function(otherFollowers) {
    var $this = this;

    $this.on('mousedown.followDrag', function (e) {
      var lastX = e.pageX;
      var lastY = e.pageY;
      $('body').on('mousemove.followDrag', function (e) {
        var deltaX = e.pageX - lastX;
        var deltaY = e.pageY - lastY;

        $this.add(otherFollowers).each(function() {
          $(this).offset({
            left: $(this).offset().left + deltaX,
            top:  $(this).offset().top  + deltaY
          });
        });

        lastX = e.pageX;
        lastY = e.pageY;
      });

      $('body').on('mouseup.followDrag', function (e) {
        console.log('mouseup');
        $('body').off('mousemove.followDrag');
      });
    });

    return {
      off: function () {
        $this.off('.followDrag');
      }
    }
  };
})( jQuery );
