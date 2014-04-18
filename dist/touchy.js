(function() {
  var Swipe, Touchy, swiper, trx, u,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  trx = require('tiny-rx');

  Swipe = require('./swipe');

  u = require('./util');

  swiper = void 0;

  Touchy = (function() {
    function Touchy(mainElement, swipeContainer, scrollingClass) {
      var $debug, easeOutScroll, easeOutSwipe, gesture, gestureHistory, scrollAnimation, self, timeoutId, touchHistory;
      this.mainElement = mainElement != null ? mainElement : '.touchy';
      this.swipeContainer = swipeContainer != null ? swipeContainer : '.swipe';
      this.scrollingClass = scrollingClass != null ? scrollingClass : 'scroll';
      this.bindEvents = __bind(this.bindEvents, this);
      this.touches = trx.createStream();
      self = this;
      scrollAnimation = void 0;
      timeoutId = void 0;
      swiper = new Swipe();
      touchHistory = this.touches.map(function(e) {
        return {
          target: e.target,
          type: e.type,
          x: e.changedTouches[0].clientX,
          y: e.changedTouches[0].clientY
        };
      }).createHistory(6).filter(function(events) {
        return events.length > 2;
      });
      gestureHistory = this.touches.map(function(e) {
        return {
          type: e.type,
          x: e.changedTouches[0].clientX,
          y: e.changedTouches[0].clientY
        };
      }).createHistory();
      gesture = void 0;
      gestureHistory.filter(function(events) {
        return events.length > 1;
      }).subscribe(function(events) {
        var first, last, moveX, moveY;
        first = u.get(events, 0);
        last = u.get(events, -1);
        if (first.type === 'touchstart') {
          moveX = last.x - first.x;
          moveY = last.y - first.y;
          if (Math.abs(moveX) < 6 && Math.abs(moveY) < 6) {
            gesture = 'tap';
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
      $debug = document.querySelector('.debug');
      this.taps = this.touches.filter(function(e) {
        return gesture === 'tap' && e.type === 'touchend';
      });
      this.taps.subscribe(function(e) {
        console.log('tap');
        setTimeout(function() {
          return $debug.textContent = '';
        }, 400);
        return gesture = void 0;
      });
      this.touches.filter('type', 'touchend').subscribe(function(e) {
        gestureHistory.reset();
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
          distance = u.get(events, -2).y - u.get(events, -1).y;
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
          distance = u.get(events, -2).x - u.get(events, -1).x;
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
        distance = u.get(events, 0).y - u.get(events, -1).y;
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
