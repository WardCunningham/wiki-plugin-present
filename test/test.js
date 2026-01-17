// build time tests for present plugin
// see http://mochajs.org/

import { present } from '../src/client/present.js'
import expect from 'expect.js'

describe('present plugin', () => {
  describe('expand', () => {
    it('can make itallic', () => {
      const result = present.expand('hello *world*')
      expect(result).to.be('hello <i>world</i>')
    })
  })
  describe('elapsed', () => {
    it('can do sub-minute', () => {
      const result = present.elapsed(10 * 1000)
      expect(result).to.be('a minute ago')
    })
    it('can do minutes', () => {
      const result = present.elapsed(10 * 60 * 1000)
      expect(result).to.be('10 minutes ago')
    })
    it('can do hours', () => {
      const result = present.elapsed(10 * 60 * 60 * 1000)
      expect(result).to.be('10 hours ago')
    })
    it('can do days', () => {
      const result = present.elapsed(10 * 24 * 60 * 60 * 1000)
      expect(result).to.be('10 days ago')
    })
    it('can do weeks', () => {
      const result = present.elapsed(3 * 7 * 24 * 60 * 60 * 1000)
      expect(result).to.be('3 weeks ago')
    })
    it('can do months', () => {
      const result = present.elapsed(10 * 30 * 24 * 60 * 60 * 1000)
      expect(result).to.be('10 months ago')
    })
    it('can do years', () => {
      const result = present.elapsed(10 * 365 * 24 * 60 * 60 * 1000)
      expect(result).to.be('10 years ago')
    })
  })
})
