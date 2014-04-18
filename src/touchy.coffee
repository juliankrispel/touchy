trx = require('tiny-rx')
Swipe = require('./swipe')
u = require('./util')
swiper = undefined

# Use:
# new Touchy(
#   mainElement: '.main',
#   swipeContainer: '.swipe',
#   scrollingClass: 'scroll'
# )
#

class Touchy
    constructor: (@mainElement = '.touchy', @swipeContainer = '.swipe', @scrollingClass = 'scroll') ->
        @touches = trx.createStream()
        #Get all touch events on keyboard container
        self = @

        scrollAnimation = undefined
        timeoutId = undefined

        swiper = new Swipe()

        # Filter touch movements. There are 3 possibilities:
        # - Sliding our finger horizontally
        # - vertically 
        # - or tapping it
        # If one of each is detected, lock them in until a touchend event
        touchHistory = @touches.map((e)-> {target: e.target, type: e.type, x: e.changedTouches[0].clientX, y: e.changedTouches[0].clientY}).createHistory(6).filter((events)->
            events.length > 2
        )

        gestureHistory = @touches.map((e)-> {type: e.type, x: e.changedTouches[0].clientX, y: e.changedTouches[0].clientY}).createHistory()

        gesture = undefined

        gestureHistory.filter((events)->
            events.length > 1
        ).subscribe((events)->
            first = u.get(events, 0)
            last = u.get(events, -1)

            if(first.type == 'touchstart')
                moveX = last.x - first.x
                moveY = last.y - first.y
                if (Math.abs(moveX) < 6 && Math.abs(moveY) < 6)
                    gesture = 'tap'
                else if(Math.abs(moveX) > Math.abs(moveY))
                    gesture = 'swipe'
                    gestureHistory.reset()
                else
                    gesture = 'scroll'
                    gestureHistory.reset()
                undefined

        )
        $debug = document.querySelector('.debug')

        @taps = @touches.filter((e)-> 
            gesture == 'tap' && e.type == 'touchend'
        )
        @taps.subscribe((e)-> 
            console.log('tap')
            setTimeout(()-> 
                $debug.textContent = ''
            , 400)
            gesture = undefined)

        @touches.filter('type', 'touchend').subscribe((e)-> 
            gestureHistory.reset()
            gesture = undefined
        )

        @swipes = touchHistory.filter(()-> gesture == 'swipe')
        @scrolls = touchHistory.filter(()-> gesture == 'scroll')

        easeOutScroll = @scrolls.filter((events)->
            if(u.get(events, -1).type == 'touchmove')
                distance = u.get(events, -2).y - u.get(events, -1).y
                $target = u.get(events,-1).target
                if($target.className.indexOf(self.scrollingClass) < 0)
                    $target = u.getParent($target, 'className', self.scrollingClass)
                $target.scrollTop+=distance if ($target)
                scrollAnimation = undefined
            else if(u.get(events, -1).type == 'touchend')
                gesture = undefined
                return true
            false
        )

        easeOutSwipe = @swipes.filter((events)->
            last = u.get(events,-1)
            if(last.type == 'touchmove')
                distance = u.get(events,-2).x - u.get(events,-1).x

                $target = u.get(events,-2).target
                swiper.moveRel(distance)
            
            else if(last.type == 'touchend' && events.length > 3)
                gesture = undefined
                return true
            false
        )

        #Easing out slide
        easeOutScroll.subscribe((events)->
            el = u.get(events, -1).target
            distance = u.get(events,0).y - u.get(events, -1).y
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

    bindEvents: ()=>
        swiper.init(@swipeContainer)
        @touches.addDomEvent(['touchstart', 'touchmove', 'touchend'], @mainElement)

module.exports = Touchy
window.Touchy = Touchy if(window)
