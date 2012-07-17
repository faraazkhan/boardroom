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
  $.fn.followDrag = function(opts) {
    var $this = this;

    var settings = $.extend(true, {
      otherFollowers : [],
      onMouseMove : function() {},
      onMouseUp : function() {},
      position : function(dx, dy, x, y) { return {left: x, top: y}; }
    }, opts)

    $this.on('mousedown.followDrag', function (e) {
      var origX = lastX = e.pageX;
      var origY = lastY = e.pageY;
      var origLeft = $this.offset().left;
      var origTop = $this.offset().top;

      $(window).on('mousemove.followDrag', function (e) {
        var deltaX = e.pageX - origX;
        var deltaY = e.pageY - origY;

        var offsetX = origLeft + deltaX;
        var offsetY = origTop  + deltaY;

        var offset = settings.position(deltaX, deltaY, offsetX, offsetY, e);

        $this.add(settings.otherFollowers).each(function() {
          $(this).offset({
            left: offset.left,
            top:  offset.top
          });
        });

        lastX = e.pageX;
        lastY = e.pageY;

        settings.onMouseMove();
      });

      $(window).on('mouseup.followDrag', function (e) {
        console.log('mouseup');
        $(window).off('mousemove.followDrag');
        settings.onMouseUp();
      });
    });
    return $this
  };
})( jQuery );
