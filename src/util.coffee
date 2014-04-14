module.exports = {
    mouseToScreen: (xmouse, ymouse) ->
        box = $.canvas.getClientRects()[0]
        [
            xmouse - box.left
            ymouse - box.top
        ]

    isKey: (keyCode, keyName) ->
        keyName.charCodeAt() == keyCode
}
