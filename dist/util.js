(function() {
  module.exports = {
    mouseToScreen: function(xmouse, ymouse) {
      var box;
      box = $.canvas.getClientRects()[0];
      return [xmouse - box.left, ymouse - box.top];
    },
    isKey: function(keyCode, keyName) {
      return keyName.charCodeAt() === keyCode;
    },
    get: function(arr, index) {
      if (index < 0) {
        return arr[arr.length + index];
      } else {
        return arr[index];
      }
    },
    getParent: function($element, attr, value) {
      var $target;
      $target = $element.parentNode;
      while ($target && $target[attr].indexOf(value) < 0) {
        if ($target.nodeName === 'HTML') {
          $target = void 0;
          break;
        }
        $target = $target.parentNode;
      }
      return $target;
    }
  };

  if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function(callback) {
      var currTime, id, lastTime, timeToCall;
      currTime = new Date().getTime();
      timeToCall = Math.max(0, 16 - (currTime - lastTime));
      id = window.setTimeout;
      (function() {
        return callback(currTime + timeToCall, timeToCall);
      });
      lastTime = currTime + timeToCall;
      return id;
    };
  }

  if (!window.cancelAnimationFrame) {
    window.cancelAnimationFrame = function(id) {
      return clearTimeout(id);
    };
  }

}).call(this);
