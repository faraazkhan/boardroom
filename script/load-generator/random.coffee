class Random
  number: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  x: -> @number 0, 800
  y: -> @number 0, 500
  move: -> @number -10, 10
  char: -> String.fromCharCode(@number 32, 126)
  pause: -> @number 100, 500
  color: -> @number 0, 4

module.exports = new Random()
