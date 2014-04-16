trx = require('tiny-rx')
module.exports = class Swiper
    constructor: (containerSelector = '.swipe', wrapSelector = '.swipe-wrap', itemSelector = '.swipe-item', @defaultSpeed = 400)->
        self = @
        @manualPosition = 0
        @swipe = document.querySelector(containerSelector)
        @swipeWrap = document.querySelector(wrapSelector)
        @slides = []
        for slide in document.querySelectorAll(itemSelector)
            @slides.push(slide) 

        if(!@swipe || !@swipeWrap || @slides.length < 2)
            throw new Error('swipe swipeWrap or slides have invalid content')

        swipeDimensions = @swipe.getBoundingClientRect()
        @slideWidth = swipeDimensions.width
        @swipeWrap.style.width = (@slides.length * @slideWidth) + 'px'


        for slide, i in @slides
            slide.style.width = @slideWidth + 'px'

        @currentIndex = 0
        @slide()
        @swipe.style.visibility = 'visible'
        @positionContinuously()
        trx.fromDomEvent('webkitTransitionEnd', @swipe)
            .subscribe((e)->
                self.positionContinuously()
            )

    prev: () ->
        if(@currentIndex <= 0)
            @currentIndex = @slides.length - 1
        else
            @currentIndex--
        @slide()

    next: () ->
        if(@currentIndex >= @slides.length - 1)
            @currentIndex = 0
        else
            @currentIndex++

        @slide()

    slide: (index, speed)->
        self = @
        self.move(index, speed)

    move: (index = @currentIndex, speed)->
        for slide, i in @slides
            @translate(i, i*@slideWidth - (index*@slideWidth), speed)

    positionContinuously: ()->
        last = @slides.length - 1
        first = 0
        if(@currentIndex == last)
            firstSlide = @slides.shift()
            @slides.push(firstSlide)
            @currentIndex--
            @move(@currentIndex, 0)
        else if(@currentIndex == first)
            lastSlide = @slides.pop()
            @currentIndex++
            @slides.unshift(lastSlide)
            @move(@currentIndex, 0)

    moveRel: (dist)->
        @manualPosition+=dist
        for slide, i in @slides
            @translate(i, i*@slideWidth - (@currentIndex*@slideWidth) - @manualPosition, 0)
    letGo: ()=>
        if(@manualPosition > @slideWidth/2)
            @next()
        else if(@manualPosition < -@slideWidth/2)
            @prev()
        else
            @move()
        @manualPosition = 0

    translate: (index, dist, speed = @defaultSpeed) ->
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

