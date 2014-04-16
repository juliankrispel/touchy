module.exports = {
    mouseToScreen: (xmouse, ymouse) ->
        box = $.canvas.getClientRects()[0]
        [
            xmouse - box.left
            ymouse - box.top
        ]

    isKey: (keyCode, keyName) ->
        keyName.charCodeAt() == keyCode

    get: (arr, index) ->
        if(index < 0)
            arr[arr.length + index]
        else
            arr[index]


    getParent: ($element, attr, value)->
        $target = $element.parentNode
        while ($target && $target[attr].indexOf(value) < 0)
            if($target.nodeName == 'HTML')
                $target = undefined
                break
            $target = $target.parentNode
        $target
}

unless window.requestAnimationFrame
  window.requestAnimationFrame = (callback) ->
    currTime = new Date().getTime()
    timeToCall = Math.max(0, 16 - (currTime - lastTime))
    id = window.setTimeout
    (->
      callback currTime + timeToCall
      , timeToCall
    )
    lastTime = currTime + timeToCall
    id

unless window.cancelAnimationFrame
  window.cancelAnimationFrame = (id) ->
    clearTimeout id
