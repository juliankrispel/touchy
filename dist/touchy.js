(function() {
  var Swipe, Touchy, swiper, trx, u,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  trx = require('tiny-rx');

  Swipe = require('./swipe');

  u = require('./util');

  swiper = void 0;

  Touchy = (function() {
    function Touchy(mainElement, swipeContainer, scrollingClass) {
      var easeOutScroll, easeOutSwipe, gesture, gestureHistory, scrollAnimation, self, timeoutId, touchHistory, whichGesture;
      this.mainElement = mainElement != null ? mainElement : '.touchy';
      this.swipeContainer = swipeContainer != null ? swipeContainer : '.swipe';
      this.scrollingClass = scrollingClass != null ? scrollingClass : 'scroll';
      this.bindEvents = __bind(this.bindEvents, this);
      this.touches = trx.createStream();
      self = this;
      scrollAnimation = void 0;
      timeoutId = void 0;
      swiper = new Swipe();
      touchHistory = this.touches.createHistory(6).filter(function(events) {
        return events.length > 2;
      });
      gestureHistory = this.touches.createHistory(6);
      gesture = void 0;
      whichGesture = gestureHistory.filter(function(events) {
        return events.length > 5;
      }).subscribe(function(events) {
        var first, last, moveX, moveY;
        first = u.get(events, 0);
        last = u.get(events, -1);
        if (first.type === 'touchstart') {
          moveX = last.changedTouches[0].clientX - first.changedTouches[0].clientX;
          moveY = last.changedTouches[0].clientY - first.changedTouches[0].clientY;
          if (Math.abs(moveX) < 4 && Math.abs(moveY) < 4) {
            gesture = 'tap';
            gestureHistory.reset();
          } else if (Math.abs(moveX) > Math.abs(moveY)) {
            gesture = 'swipe';
            gestureHistory.reset();
          } else {
            gesture = 'scroll';
            gestureHistory.reset();
          }
          return void 0;
        }
      });
      this.taps = this.touches.filter(function(e) {
        return gesture === 'tap' && e.type === 'touchend';
      });
      this.taps.subscribe(function(e) {
        return gesture = void 0;
      });
      this.swipes = touchHistory.filter(function() {
        return gesture === 'swipe';
      });
      this.scrolls = touchHistory.filter(function() {
        return gesture === 'scroll';
      });
      easeOutScroll = this.scrolls.filter(function(events) {
        var $target, distance;
        if (u.get(events, -1).type === 'touchmove') {
          distance = u.get(events, -2).touches[0].clientY - u.get(events, -1).touches[0].clientY;
          $target = u.get(events, -1).target;
          if ($target.className.indexOf(self.scrollingClass) < 0) {
            $target = u.getParent($target, 'className', self.scrollingClass);
          }
          if ($target) {
            $target.scrollTop += distance;
          }
          scrollAnimation = void 0;
        } else if (u.get(events, -1).type === 'touchend') {
          gesture = void 0;
          return true;
        }
        return false;
      });
      easeOutSwipe = this.swipes.filter(function(events) {
        var $target, distance, last;
        last = u.get(events, -1);
        if (last.type === 'touchmove') {
          distance = u.get(events, -2).touches[0].clientX - u.get(events, -1).touches[0].clientX;
          $target = u.get(events, -2).target;
          swiper.moveRel(distance);
        } else if (last.type === 'touchend' && events.length > 3) {
          gesture = void 0;
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
      easeOutSwipe.subscribe(function(e) {
        return swiper.letGo();
      });
    }

    Touchy.prototype.bindEvents = function() {
      swiper.init(this.swipeContainer);
      return this.touches.addDomEvent(['touchstart', 'touchmove', 'touchend'], this.mainElement);
    };

    return Touchy;

  })();

  module.exports = Touchy;

  if (window) {
    window.Touchy = Touchy;
  }

}).call(this);
