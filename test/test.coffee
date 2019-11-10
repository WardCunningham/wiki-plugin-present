# build time tests for present plugin
# see http://mochajs.org/

present = require '../client/present'
expect = require 'expect.js'

describe 'present plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = present.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'

  describe 'elapsed', ->

    it 'can do sub-minute', ->
      result = present.elapsed 10*1000
      expect(result).to.be 'a minute ago'

    it 'can do minutes', ->
      result = present.elapsed 10*60*1000
      expect(result).to.be '10 minutes ago'

    it 'can do hours', ->
      result = present.elapsed 10*60*60*1000
      expect(result).to.be '10 hours ago'

    it 'can do days', ->
      result = present.elapsed 10*24*60*60*1000
      expect(result).to.be '10 days ago'

    it 'can do weeks', ->
      result = present.elapsed 3*7*24*60*60*1000
      expect(result).to.be '3 weeks ago'

    it 'can do months', ->
      result = present.elapsed 10*30*24*60*60*1000
      expect(result).to.be '10 months ago'

    it 'can do years', ->
      result = present.elapsed 10*365*24*60*60*1000
      expect(result).to.be '10 years ago'
