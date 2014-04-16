(function() {
  var Swipe, Touchy, trx, u;

  trx = require('tiny-rx');

  Swipe = require('./swipe');

  u = require('./util');

  Touchy = (function() {
    function Touchy(mainElement, swipeContainer, scrollingClass) {
      this.mainElement = mainElement != null ? mainElement : '.touchy';
      this.swipeContainer = swipeContainer != null ? swipeContainer : '.swipe';
      this.scrollingClass = scrollingClass != null ? scrollingClass : 'scroll';
    }

    Touchy.prototype.bindEvents = function() {
      var easeOutScroll, easeOutSwipe, gestureLock, lastTouchEvent, scroll, scrollAnimation, swipe, swiper, tapEvents, timeoutId, touchEvents, touchHistory;
      this.touchEvents = touchEvents = trx.fromDomEvent(['touchstart', 'touchmove', 'touchend'], this.mainElement);
      scrollAnimation = void 0;
      gestureLock = void 0;
      timeoutId = void 0;
      swiper = new Swipe(this.swipeContainer);
      this.tapEvents = tapEvents = touchEvents.filter(function(e) {
        var result;
        result = e.type === 'touchend' && gestureLock && gestureLock.type === 'tapstart';
        if (result) {
          gestureLock = void 0;
        }
        return result;
      });
      lastTouchEvent = touchEvents.createHistory(1);
      touchEvents.subscribe(function(e) {
        if (e.type === 'touchstart') {
          return timeoutId = setTimeout(function() {
            var lastEvent, moveX, moveY;
            lastEvent = lastTouchEvent.value()[0];
            moveX = lastEvent.changedTouches[0].clientX - e.changedTouches[0].clientX;
            moveY = lastEvent.changedTouches[0].clientY - e.changedTouches[0].clientY;
            if (Math.abs(moveX) < 4 && Math.abs(moveY) < 4) {
              return gestureLock = {
                startEvent: e,
                type: 'tapstart'
              };
            } else if (Math.abs(moveX) > Math.abs(moveY)) {
              return gestureLock = {
                startEvent: e,
                type: 'swipestart',
                movement: moveX
              };
            } else {
              return gestureLock = {
                startEvent: e,
                type: 'scrollstart',
                movement: moveY
              };
            }
          }, 100);
        } else if (e.type === 'touchend' && !gestureLock) {
          clearInterval(timeoutId);
          return tapEvents.publish(e);
        }
      });
      touchHistory = touchEvents.createHistory(6);
      touchHistory.filter(function(events) {
        return events.length > 1;
      });
      this.swipeEvents = swipe = touchHistory.filter(function(e) {
        var result;
        return result = gestureLock && gestureLock.type === 'swipestart';
      });
      this.scrollEvents = scroll = touchHistory.filter(function(e) {
        return gestureLock && gestureLock.type === 'scrollstart';
      });
      easeOutScroll = scroll.filter(function(events) {
        var $target, distance;
        if (u.get(events, -1).type === 'touchmove') {
          distance = u.get(events, -2).touches[0].clientY - u.get(events, -1).touches[0].clientY;
          $target = u.get(events, -1).target;
          if ($target.className.indexOf(this.scrollingClass) < 0) {
            $target = u.getParent($target, 'className', this.scrollingClass);
          }
          $target.scrollTop += distance;
          scrollAnimation = void 0;
        } else if (u.get(events, -1).type === 'touchend') {
          gestureLock = void 0;
          return true;
        }
        return false;
      });
      easeOutSwipe = swipe.filter(function(events) {
        var $target, distance;
        if (u.get(events, -1).type === 'touchmove') {
          distance = u.get(events, -2).touches[0].clientX - u.get(events, -1).touches[0].clientX;
          $target = u.get(events, -2).target;
          swiper.moveRel(distance);
        } else if (u.get(events, -1).type === 'touchend' && events.length > 3) {
          gestureLock = void 0;
          return true;
        }
        return false;
      });
      easeOutScroll.subscribe(function(events) {
        var distance, el, targetPosition;
        el = u.get(events, -1).target;
        distance = u.get(events, 0).changedTouches[0].clientY - u.get(events, -1).changedTouches[0].clientY;
        targetPosition = (distance * (Math.abs(distance) * 2)) + u.get(events, -2).target.scrollTop;
        scrollAnimation = function() {
          var dist;
          dist = targetPosition - el.scrollTop;
          if (Math.abs(dist) < .5) {
            scrollAnimation = void 0;
          }
          el.scrollTop += dist / 10;
          if (typeof scrollAnimation === 'function') {
            return requestAnimationFrame(scrollAnimation);
          }
        };
        return requestAnimationFrame(scrollAnimation);
      });
      return easeOutSwipe.subscribe(function(e) {
        return swiper.letGo();
      });
    };

    return Touchy;

  })();

  module.exports = Touchy;

}).call(this);
