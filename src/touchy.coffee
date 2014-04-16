trx = require('tiny-rx')
Swipe = require('./swipe')
u = require('./util')

# Use:
# new Touchy(
#   mainElement: '.main',
#   swipeContainer: '.swipe',
#   scrollingClass: 'scroll'
# )
#

class Touchy
    constructor: (@mainElement = '.touchy', @swipeContainer = '.swipe', @scrollingClass = 'scroll') ->

    bindEvents: ()->
        #Get all touch events on keyboard container
        @touchEvents = touchEvents = trx.fromDomEvent(['touchstart', 'touchmove', 'touchend'], @mainElement)

        scrollAnimation = undefined
        gestureLock = undefined
        timeoutId = undefined

        swiper = new Swipe(@swipeContainer)
        @tapEvents = tapEvents = touchEvents.filter((e)->
            result = e.type == 'touchend' && gestureLock && gestureLock.type == 'tapstart'
            gestureLock = undefined if result
            result
        )

        # Filter touch movements. There are 3 possibilities:
        # - Sliding our finger horizontally
        # - vertically 
        # - or tapping it
        # If one of each is detected, lock them in until a touchend event
        lastTouchEvent = touchEvents.createHistory(1)

        touchEvents.subscribe((e)->
            if(e.type == 'touchstart')
                timeoutId = setTimeout(()->
                    lastEvent = lastTouchEvent.value()[0]
                    moveX = lastEvent.changedTouches[0].clientX - e.changedTouches[0].clientX
                    moveY = lastEvent.changedTouches[0].clientY - e.changedTouches[0].clientY
                    if (Math.abs(moveX) < 4 && Math.abs(moveY) < 4)
                        gestureLock = {startEvent: e, type: 'tapstart'}
                    else if(Math.abs(moveX) > Math.abs(moveY))
                        gestureLock = {startEvent: e, type: 'swipestart', movement: moveX}
                    else
                        gestureLock = {startEvent: e, type: 'scrollstart', movement: moveY}
                , 100)
            else if(e.type == 'touchend' && !gestureLock)
                clearInterval(timeoutId)
                tapEvents.publish(e)
        )

        touchHistory = touchEvents.createHistory(6)
        touchHistory.filter((events)->
            events.length > 1
        )

        @swipeEvents = swipe = touchHistory.filter((e)-> 
            result = gestureLock && gestureLock.type == 'swipestart'
        )


        @scrollEvents = scroll = touchHistory.filter((e)-> 
            gestureLock && gestureLock.type == 'scrollstart'
        )

        easeOutScroll = scroll.filter((events)->
            if(u.get(events, -1).type == 'touchmove')
                distance = u.get(events, -2).touches[0].clientY - u.get(events, -1).touches[0].clientY
                $target = u.get(events,-1).target
                if($target.className.indexOf(@scrollingClass) < 0)
                    $target = u.getParent($target, 'className', @scrollingClass)
                $target.scrollTop+=distance
                scrollAnimation = undefined
            else if(u.get(events, -1).type == 'touchend')
                gestureLock = undefined
                return true
            false
        )

        easeOutSwipe = swipe.filter((events)->
            if(u.get(events,-1).type == 'touchmove')
                distance = u.get(events,-2).touches[0].clientX - u.get(events,-1).touches[0].clientX

                $target = u.get(events,-2).target
                swiper.moveRel(distance)
            
            else if(u.get(events,-1).type == 'touchend' && events.length > 3)
                gestureLock = undefined
                return true
            false
        )

        #Easing out slide
        easeOutScroll.subscribe((events)->
            el = u.get(events, -1).target
            distance = u.get(events,0).changedTouches[0].clientY - u.get(events, -1).changedTouches[0].clientY
            targetPosition = (distance * (Math.abs(distance)*2)) + u.get(events,-2).target.scrollTop

            scrollAnimation = () ->
                dist = targetPosition - el.scrollTop
                if(Math.abs(dist) < .5)
                    scrollAnimation = undefined
                el.scrollTop+= dist/10
                requestAnimationFrame(scrollAnimation) if typeof scrollAnimation == 'function'
            requestAnimationFrame(scrollAnimation)
        )

        easeOutSwipe.subscribe((e)->
            swiper.letGo()
        )

module.exports = Touchy
