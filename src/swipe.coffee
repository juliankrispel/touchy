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
        )
        @swiped.subscribe((e)->
            console.log('position', e)
        )

    prev: () ->
        @setPositionRelative(-1)
        if(@_index <= 0)
            @move(@slides.length - 1)
        else
            @move(@_index - 1)

    next: () ->
        @setPositionRelative(1)
        if(@_index >= @slides.length - 1)
            @move(0)
        else
            @move(@_index + 1)

    slide: (index, speed)->
        self = @
        self.move(index, speed)

    move: (index = @_index, speed)=>
        @_index = index
        for slide, i in @slides
            @translate(i, i*@slideWidth - (index*@slideWidth), speed)

    positionContinuously: ()->
        last = @slides.length - 1
        first = 0
        if(@_index == last)
            firstSlide = @slides.shift()
            @slides.push(firstSlide)
            @move(@_index - 1, 0)
        else if(@_index == first)
            lastSlide = @slides.pop()
            @slides.unshift(lastSlide)
            @move(@_index + 1, 0)

    moveRel: (dist)->
        if(@transitionInProgress)
            @transitionEnd.publish()

        @manualPosition+=dist
        for slide, i in @slides
            @translate(i, i*@slideWidth - (@_index*@slideWidth) - @manualPosition, 0)

    setPositionRelative: (moveRel) =>
        target = @currentPosition + moveRel
        lastSlide = @slides.length - 1
        if(target > lastSlide)
            target = target - lastSlide - 1
        else if (target < 0)
            target = lastSlide - target + 1

        @currentPosition = target
        @swiped.publish(@currentPosition)

    slideTo: (num) =>
        if(!num)
            return
        moveTo = @_index + (num - @currentPosition)
        lastSlide = @slides.length - 1
        @setPositionRelative(num - @currentPosition)
        if(moveTo > lastSlide)
            moveTo = moveTo - lastSlide - 1
        else if (moveTo < 0)
            moveTo = lastSlide + moveTo
            
        @move(moveTo)

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

