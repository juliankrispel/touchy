trx = require('tiny-rx')
_ = require('lodash')
Swipe = require('./swipe.coffee')

get = (arr, index) ->
    if(index < 0)
        arr[arr.length + index]
    else
        arr[index]

swipe = new Swipe()

getParent = ($element, attr, value)->
    $target = $element.parentNode
    while ($target && $target[attr].indexOf(value) < 0)
        if($target.nodeName == 'HTML')
            $target = undefined
            break
        $target = $target.parentNode
    $target

# Easing  taken from overthrow.js
# t = current iteration, b = initial value, c = end value, d = total iterations
easing = (t, b, c, d)->
    c*((t=t/d-1)*t*t + 1) + b

#Get all touch events on keyboard container
touchEvents = trx.fromDomEvent(['touchstart', 'touchmove', 'touchend'], [document.body])

scrollInterval = undefined
gestureLock = undefined
timeoutId = undefined

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
            if (Math.abs(moveX) < 5 && Math.abs(moveY) < 5)
                gestureLock = {startEvent: e, type: 'tap'}
            else if(Math.abs(moveX) > Math.abs(moveY))
                gestureLock = {startEvent: e, type: 'horizontalSlide', movement: moveX}
            else
                gestureLock = {startEvent: e, type: 'verticalSlide', movement: moveY}
        , 100)
)

slideHistory = touchEvents.createHistory(4)
slideHistory.filter((events)->
    events.length > 1
)

horizontalSlide = slideHistory.filter((e)-> gestureLock && gestureLock.type == 'horizontalSlide')
verticalSlide = slideHistory.filter((e)-> gestureLock && gestureLock.type == 'verticalSlide')
taps = touchEvents.filter((e)-> gestureLock && gestureLock.type == 'tap').filter('type', 'touchend')

taps.filter({target: {nodeName: 'BUTTON'}}).subscribe((e)-> console.log('button tapped'))

easeOutVerticalSlide = verticalSlide.filter((events)->
    if(get(events, -1).type == 'touchmove')
        distance = get(events, -2).touches[0].clientY - get(events, -1).touches[0].clientY
        $target = get(events,-1).target
        if($target.className.indexOf('scroll') < 0)
            $target = getParent($target, 'className', 'scroll')
        $target.scrollTop+=distance
        clearInterval(scrollInterval)
    else if(get(events, -1).type == 'touchend')
        return true
    false
)

easeOutHorizontalSlide = horizontalSlide.filter((events)->
    if(get(events,-1).type == 'touchmove')
        distance = get(events,-2).touches[0].clientX - get(events,-1).touches[0].clientX

        $target = get(events,-2).target
        if($target.className.indexOf('scroll') < 0)
            $target = getParent($target, 'className', 'slider')
        swipe.moveRel(distance)
    
    else if(get(events,-1).type == 'touchend' && events.length > 3)
        return true
    false
)

#Easing out slide
easeOutVerticalSlide.subscribe((events)->
    el = get(events, -1).target
    distance = get(events,0).changedTouches[0].clientY - get(events, -1).changedTouches[0].clientY
    targetPosition = (distance * (Math.abs(distance)*4)) + get(events,-2).target.scrollTop
    scrollInterval = setInterval(()->
        dist = targetPosition - el.scrollTop
        if(Math.abs(dist) < .5)
            clearInterval(scrollInterval)
        el.scrollTop+= dist/5
    , 30)
)

easeOutHorizontalSlide.subscribe((e)->
    swipe.letGo()
)
