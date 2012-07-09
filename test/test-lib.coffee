global.jQuery = global.$ = require('jquery')
require('../public/js/lib.js')

describe 'removeClassMatching', () ->
  it 'does nothing when there are no matches', () ->
    div = $('<div class="onefish">')
    div.removeClassMatching(/twofish/)
    expect(div.attr('class')).to.equal('onefish')

  it 'removes a single class that matches', () ->
    div = $('<div class="onefish twofish">')
    div.removeClassMatching(/twofish/)
    expect(div.attr('class')).to.equal('onefish')

  it 'removes all classes that match with a /g regex', () ->
    div = $('<div class="onefish twofish">')
    div.removeClassMatching(/\w*fish/g)
    expect(div.attr('class')).to.equal('')

  it 'removes a single class that matches 2 jQuery objects', () ->
    divs = $('<div class="onefish twofish"></div><div class="twofish bluefish"></div>')
    divs.removeClassMatching(/twofish/)
    expect(divs.eq(0).attr('class')).to.equal('onefish')
    expect(divs.eq(1).attr('class')).to.equal('bluefish')

  it 'removes different classes that match 2 jQuery objects', () ->
    divs = $('<div class="onefish twofish"></div><div class="redfish bluefish"></div>')
    divs.removeClassMatching(/\w+efish/)
    expect(divs.eq(0).attr('class')).to.equal('twofish')
    expect(divs.eq(1).attr('class')).to.equal('redfish')