$ ->
    randomizeBackgroundImage()
    addFormInteractivity()

randomizeBackgroundImage = ->
    random = Math.floor(Math.random() * 5 + 1)
    prefix = "/images/bg_"
    suffix = ".jpg"

    image_url = prefix + random + suffix
    $.backstretch image_url, fade: 800


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

    validTwitterOrEmail = (input) =>
      console.log "validating"
      validTwitter = (str) -> if str.match(/\@/) then true else false
      validEmail   = (str) -> if str.match(/\A[^@]+@[^@\.]+\.+[^@\.]+\z/) then true else false
      return validTwitter(input) or validEmail(input)

    $("form").submit ->
        input = $("#user_id").get(0)
        if input.value is input.defaultValue
            input.value = ""
        if validTwitterOrEmail(input.value)
          return true
        else
          input.value = "Enter @twitter username or email@address.com"
          return false
