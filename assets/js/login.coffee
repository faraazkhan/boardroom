$ ->
    randomizeBackgroundImage()
    addFormInteractivity()

randomizeBackgroundImage = ->
    random = Math.floor(Math.random() * 5 + 1)
    bodyBackgroundClassPrefix = "background_"

    bodyBackgroundClass = bodyBackgroundClassPrefix + random

    $("body").removeClass((index, cssClass) ->
        matches = cssClass.match(/background_\d/) or []
        matches.join " "
    ).addClass bodyBackgroundClass;

addFormInteractivity = ->
    $('input[type="text"]').focus ->
        that = this
        if that.value is that.defaultValue
            that.value = ""
        else
            setTimeout -> 
                that.select() 10

    $("input[type='text']").blur ->
        @value = @defaultValue if @value is ""

    $("form").submit ->
        input = $("#user_id").get(0)
        if input.value is input.defaultValue
            console.log("match");
            input.value = ""    
        return true;