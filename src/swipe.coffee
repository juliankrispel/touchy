trx = require('tiny-rx')
module.exports = class Swiper
    init: (containerSelector = '.swipe', wrapSelector = '.swipe-wrap', itemSelector = '.swipe-item', @defaultSpeed = 400)->
        self = @
        window.s = self
        @manualPosition = 0
        @transitionInProgress = false
        @swipe = document.querySelector(containerSelector)
        @swipeWrap = document.querySelector(wrapSelector)
        @swiped = trx.createStream()
        @slides = []
        for slide in document.querySelectorAll(itemSelector)
            @slides.push(slide) 

        if(!@swipe || !@swipeWrap || @slides.length < 2)
            throw new Error('swipe swipeWrap or swipeItems are not valid elements')

        swipeDimensions = @swipe.getBoundingClientRect()
        @slideWidth = swipeDimensions.width
        @swipeWrap.style.width = (@slides.length * @slideWidth) + 'px'


        for slide, i in @slides
            slide.style.width = @slideWidth + 'px'

        @currentPosition = 0
        @_index = 0
        
        @slide(undefined, 0)
        @swipe.style.visibility = 'visible'
        @positionContinuously()
        @transitionEnd = trx.fromDomEvent('webkitTransitionEnd', @swipe);
        @transitionEnd.subscribe(()->
            self.transitionInProgress = false
            self.positionContinuously()
            self.swiped.publish(self.currentPosition)
        )

    prev: () ->
        if(@_index <= 0)
            @_index = @slides.length - 1
        else
            @_index--

        if(@currentPosition <= 0)
            @currentPosition = @slides.length - 1
        else
            @currentPosition--

        @slide()

    next: () ->
        if(@_index >= @slides.length - 1)
            @_index = 0
        else
            @_index++

        if(@currentPosition >= @slides.length - 1)
            @currentPosition = 0
        else
            @currentPosition++

        @slide()

    slide: (index, speed)->
        self = @
        self.move(index, speed)

    move: (index = @_index, speed)=>
        for slide, i in @slides
            @translate(i, i*@slideWidth - (index*@slideWidth), speed)

    positionContinuously: ()->
        last = @slides.length - 1
        first = 0
        if(@_index == last)
            firstSlide = @slides.shift()
            @slides.push(firstSlide)
            @_index--
            @move(@_index, 0)
        else if(@_index == first)
            lastSlide = @slides.pop()
            @_index++
            @slides.unshift(lastSlide)
            @move(@_index, 0)

    moveRel: (dist)->
        if(@transitionInProgress)
            @transitionEnd.publish()

        @manualPosition+=dist
        for slide, i in @slides
            @translate(i, i*@slideWidth - (@_index*@slideWidth) - @manualPosition, 0)

    letGo: ()=>
        if(@manualPosition > @slideWidth/7)
            @next()
        else if(@manualPosition < -@slideWidth/3)
            @prev()
        else
            @move()
        @manualPosition = 0

    translate: (index, dist, speed = @defaultSpeed) ->
        if(speed > 0)
            @transitionInProgress = true
        slide = @slides[index]
        style = slide && slide.style
        #If transition is bigger than 1*width set transition to 0

        if (!style) 
            return false

        style.webkitTransitionDuration =
        style.MozTransitionDuration =
        style.msTransitionDuration =
        style.OTransitionDuration =
        style.transitionDuration = speed + 'ms'

        style.webkitTransform = 'translate(' + dist + 'px,0)' + 'translateZ(0)'
        style.msTransform =
        style.MozTransform =
        style.OTransform = 'translateX(' + dist + 'px)'

