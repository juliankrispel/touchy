(function() {
  var Swiper, trx,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  trx = require('tiny-rx');

  module.exports = Swiper = (function() {
    function Swiper() {
      this.letGo = __bind(this.letGo, this);
      this.move = __bind(this.move, this);
    }

    Swiper.prototype.init = function(containerSelector, wrapSelector, itemSelector, defaultSpeed) {
      var i, self, slide, swipeDimensions, _i, _j, _len, _len1, _ref, _ref1;
      if (containerSelector == null) {
        containerSelector = '.swipe';
      }
      if (wrapSelector == null) {
        wrapSelector = '.swipe-wrap';
      }
      if (itemSelector == null) {
        itemSelector = '.swipe-item';
      }
      this.defaultSpeed = defaultSpeed != null ? defaultSpeed : 400;
      self = this;
      window.s = self;
      this.manualPosition = 0;
      this.transitionInProgress = false;
      this.swipe = document.querySelector(containerSelector);
      this.swipeWrap = document.querySelector(wrapSelector);
      this.slides = [];
      _ref = document.querySelectorAll(itemSelector);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        slide = _ref[_i];
        this.slides.push(slide);
      }
      if (!this.swipe || !this.swipeWrap || this.slides.length < 2) {
        throw new Error('swipe swipeWrap or swipeItems are not valid elements');
      }
      swipeDimensions = this.swipe.getBoundingClientRect();
      this.slideWidth = swipeDimensions.width;
      this.swipeWrap.style.width = (this.slides.length * this.slideWidth) + 'px';
      _ref1 = this.slides;
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        slide = _ref1[i];
        slide.style.width = this.slideWidth + 'px';
      }
      this.currentIndex = 0;
      this.slide(void 0, 0);
      this.swipe.style.visibility = 'visible';
      this.positionContinuously();
      this.transitionEnd = trx.fromDomEvent('webkitTransitionEnd', this.swipe);
      return this.transitionEnd.subscribe(function() {
        this.transitionInProgress = false;
        return self.positionContinuously();
      });
    };

    Swiper.prototype.prev = function() {
      if (this.currentIndex <= 0) {
        this.currentIndex = this.slides.length - 1;
      } else {
        this.currentIndex--;
      }
      return this.slide();
    };

    Swiper.prototype.next = function() {
      if (this.currentIndex >= this.slides.length - 1) {
        this.currentIndex = 0;
      } else {
        this.currentIndex++;
      }
      return this.slide();
    };

    Swiper.prototype.slide = function(index, speed) {
      var self;
      self = this;
      return self.move(index, speed);
    };

    Swiper.prototype.move = function(index, speed) {
      var i, slide, _i, _len, _ref, _results;
      if (index == null) {
        index = this.currentIndex;
      }
      _ref = this.slides;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        slide = _ref[i];
        _results.push(this.translate(i, i * this.slideWidth - (index * this.slideWidth), speed));
      }
      return _results;
    };

    Swiper.prototype.positionContinuously = function() {
      var first, firstSlide, last, lastSlide;
      last = this.slides.length - 1;
      first = 0;
      if (this.currentIndex === last) {
        firstSlide = this.slides.shift();
        this.slides.push(firstSlide);
        this.currentIndex--;
        return this.move(this.currentIndex, 0);
      } else if (this.currentIndex === first) {
        lastSlide = this.slides.pop();
        this.currentIndex++;
        this.slides.unshift(lastSlide);
        return this.move(this.currentIndex, 0);
      }
    };

    Swiper.prototype.moveRel = function(dist) {
      var i, slide, _i, _len, _ref, _results;
      if (this.transitionInProgress) {
        this.transitionEnd.publish();
      }
      this.manualPosition += dist;
      _ref = this.slides;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        slide = _ref[i];
        _results.push(this.translate(i, i * this.slideWidth - (this.currentIndex * this.slideWidth) - this.manualPosition, 0));
      }
      return _results;
    };

    Swiper.prototype.letGo = function() {
      if (this.manualPosition > this.slideWidth / 7) {
        this.next();
      } else if (this.manualPosition < -this.slideWidth / 3) {
        this.prev();
      } else {
        this.move();
      }
      return this.manualPosition = 0;
    };

    Swiper.prototype.translate = function(index, dist, speed) {
      var slide, style;
      if (speed == null) {
        speed = this.defaultSpeed;
      }
      if (speed > 0) {
        this.transitionInProgress = true;
      }
      slide = this.slides[index];
      style = slide && slide.style;
      if (!style) {
        return false;
      }
      style.webkitTransitionDuration = style.MozTransitionDuration = style.msTransitionDuration = style.OTransitionDuration = style.transitionDuration = speed + 'ms';
      style.webkitTransform = 'translate(' + dist + 'px,0)' + 'translateZ(0)';
      return style.msTransform = style.MozTransform = style.OTransform = 'translateX(' + dist + 'px)';
    };

    return Swiper;

  })();

}).call(this);
