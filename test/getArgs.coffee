getArgs = require '../src/getArgs'

base = -> ['node', 'app.js']

fakeFlags = ->
  [
    '-a'
    '-b, --blah'
    '--code'
  ]

describe 'getArgs', ->

  it 'should return false by default for each flag', ->
    result = getArgs base(), fakeFlags()
    Should.exist result?.a
    Should.exist result?.blah
    Should.exist result?.code
    result.a.should.equal false
    result.blah.should.equal false
    result.code.should.equal false

  it 'should resolve short flags', ->
    args = base().concat '-b'
    result = getArgs args, fakeFlags()
    Should.exist result?.a
    Should.exist result?.blah
    Should.exist result?.code
    result.a.should.equal false
    result.blah.should.equal true
    result.code.should.equal false

  it 'should parse --debug as a flag', ->
    result = getArgs base().concat ['--debug']
    Should.exist result?.debug
    result.debug.should.equal true

  it 'should ignore flags after cmd', ->
    args = base().concat [
      '-b'
      'cmd'
      '-a'
    ]
    result = getArgs args, fakeFlags()
    Should.exist result?.a
    Should.exist result?.blah
    result.a.should.equal false
    result.blah.should.equal true
    Should.exist result?.dkcmd
    result.dkcmd.length.should.equal 2
    result.dkcmd[0].should.equal 'cmd'
    result.dkcmd[1].should.equal '-a'

  it 'should parse --blah=stuff', ->
    args = base().concat ['--blah=stuff']
    result = getArgs args, null, fakeFlags()
    Should.exist result?.blah
    result.blah.length.should.equal 1
    result.blah[0].should.equal 'stuff'

  it 'should parse --blah=stuff', ->
    args = base().concat ['--blah=stuff']
    result = getArgs args, null, ['--blah']
    Should.exist result?.blah
    result.blah.length.should.equal 1
    result.blah[0].should.equal 'stuff'

  it 'should parse --blah stuff', ->
    args = base().concat ['--blah', 'stuff']
    result = getArgs args, null, fakeFlags()
    Should.exist result?.blah
    result.blah.length.should.equal 1
    result.blah[0].should.equal 'stuff'

  it 'should parse -b stuff', ->
    args = base().concat ['-b', 'stuff']
    result = getArgs args, null, fakeFlags()
    Should.exist result?.blah
    result.blah.length.should.equal 1
    result.blah[0].should.equal 'stuff'

  it 'should parse -b stuff', ->
    args = base().concat ['-b', 'stuff']
    result = getArgs args, null, fakeFlags()
    Should.exist result?.blah
    result.blah.length.should.equal 1
    result.blah[0].should.equal 'stuff'

  it 'should parse -b stuff1 -b stuff2 --blah=stuff3 --blah stuff4', ->

    args = base().concat [
      '-b'
      'stuff0'
      '-b'
      'stuff1'
      '--blah=stuff2'
      '--blah'
      'stuff3'
    ]
    result = getArgs args, null, fakeFlags()
    Should.exist result?.blah
    result.blah.length.should.equal 4
    result.blah[0].should.equal 'stuff0'
    result.blah[1].should.equal 'stuff1'
    result.blah[2].should.equal 'stuff2'
    result.blah[3].should.equal 'stuff3'

  it 'should parse -ab stuff1', ->
    flags = [
      '-a, --apple'
    ]
    options = [
      '-b, --banana'
    ]
    args = base().concat [
      '-ab'
      'stuff'
    ]
    result = getArgs args, flags, options
    Should.exist result?.apple
    Should.exist result.banana
    result.apple.should.equal true
    result.banana.length.should.equal 1
    result.banana[0].should.equal 'stuff'
