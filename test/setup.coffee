path = require 'path'

global.Should = require 'should'

fixtures = path.join __dirname, './fixtures'

beforeEach ->
  @fixtures = fixtures
