# build time tests for present plugin
# see http://mochajs.org/

present = require '../client/present'
expect = require 'expect.js'

describe 'present plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = present.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'
