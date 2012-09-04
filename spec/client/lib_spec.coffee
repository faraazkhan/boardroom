describe 'removeClassMatching', () ->
  it 'does nothing when there are no matches', () ->
    div = $('<div class="onefish">')
    div.removeClassMatching(/twofish/)
    expect(div.attr('class')).toEqual('onefish')

  it 'removes a single class that matches', () ->
    div = $('<div class="onefish twofish">')
    div.removeClassMatching(/twofish/)
    expect(div.attr('class')).toEqual('onefish')

  it 'removes all classes that match with a /g regex', () ->
    div = $('<div class="onefish twofish">')
    div.removeClassMatching(/\w*fish/g)
    expect(div.attr('class')).toEqual('')

  it 'removes a single class that matches 2 jQuery objects', () ->
    divs = $('<div class="onefish twofish"></div><div class="twofish bluefish"></div>')
    divs.removeClassMatching(/twofish/)
    expect(divs.eq(0).attr('class')).toEqual('onefish')
    expect(divs.eq(1).attr('class')).toEqual('bluefish')

  it 'removes different classes that match 2 jQuery objects', () ->
    divs = $('<div class="onefish twofish"></div><div class="redfish bluefish"></div>')
    divs.removeClassMatching(/\w+efish/)
    expect(divs.eq(0).attr('class')).toEqual('twofish')
    expect(divs.eq(1).attr('class')).toEqual('redfish')

describe 'containsPoint', () ->
  div = $('<div style="position:absolute; width: 100px; height: 200px;">')
  # mock offset(), since there's no CSS renderer etc.
  div.offset = () ->
     {left: 50, top: 150}

  it 'is false when above left', () ->
    expect(div.containsPoint(49, 149)).toEqual(false)

  it 'is false when left', () ->
    expect(div.containsPoint(49, 200)).toEqual(false)

  it 'is false when above', () ->
    expect(div.containsPoint(125, 149)).toEqual(false)

  it 'is true when contained', () ->
    expect(div.containsPoint(125, 200)).toEqual(true)

  it 'is false when exceeding bottom boundaries', () ->
    expect(div.containsPoint(125, 351)).toEqual(false)

  it 'is false when exceeding right boundaries', () ->
    expect(div.containsPoint(151, 200)).toEqual(false)

  it 'is false when exceeding bottom right boundaries', () ->
    expect(div.containsPoint(151, 351)).toEqual(false)

 # Note: useFakeTimers seems to mess up the scheduling of asynchronous tests
 # (tests that take a done argument). If you need async, try moving them to a
 # separate file.
 describe 'onMousePause', ->
   mousepause = undefined
   div = undefined
   onMousePause = undefined

   beforeEach ->
     this.clock = sinon.useFakeTimers()

     mousepause = sinon.spy()
     div = $('<div>')
     onMousePause = div.onMousePause(mousepause, 10)
     div.trigger('mousemove')

   afterEach ->
     this.clock.restore()

   it 'fires after the specified wait', ->
     this.clock.tick(9)
     expect(mousepause.called).toEqual(false)

     this.clock.tick(2)
     expect(mousepause.called).toEqual(true)

   it 'fires after the specified wait since the last mousemove', ->
     interval = setInterval ->
       div.trigger 'mousemove'
     , 5

     setTimeout ->
       clearInterval interval
     , 50

     this.clock.tick(11)
     expect(mousepause.called).toEqual(false)

     this.clock.tick(30)
     expect(mousepause.called).toEqual(false)

     this.clock.tick(30)
     expect(mousepause.called).toEqual(true)

   it 'passes the last mousemove event through to the callback', ->
     mousemove = $.Event("mousemove")
     div.trigger(mousemove)
     this.clock.tick(11)
     expect(mousepause.calledWith(mousemove)).toEqual(true)

   describe 'off', ->
     it 'cancels any pending callback', ->
       this.clock.tick(9)
       onMousePause.off()
       this.clock.tick(2)
       expect(mousepause.called).toEqual(false)

     it 'cancels the listener', ->
       onMousePause.off()
       div.trigger('mousemove')
       this.clock.tick(11)
