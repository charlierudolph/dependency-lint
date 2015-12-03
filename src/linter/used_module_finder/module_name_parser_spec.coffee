ModuleNameParser = require './module_name_parser'


describe 'ModuleNameParser', ->

  describe 'isBuiltIn', ->
    it 'returns true for built in modules', ->
      expect(ModuleNameParser.isBuiltIn 'fs').to.be.true

    it 'returns false otherwise', ->
      expect(ModuleNameParser.isBuiltIn 'other').to.be.false


  describe 'isGlobalExecutable', ->
    it 'returns true for npm', ->
      expect(ModuleNameParser.isGlobalExecutable 'npm').to.be.true

    it 'returns false otherwise', ->
      expect(ModuleNameParser.isGlobalExecutable 'other').to.be.false


  describe 'isRelative', ->
    it 'returns true if the name starts with a dot', ->
      expect(ModuleNameParser.isRelative './helper').to.be.true

    it 'returns false otherwise', ->
      expect(ModuleNameParser.isRelative 'other').to.be.false


  describe 'stripLoaders', ->
    it 'returns modules without loaders untouched', ->
      expect(ModuleNameParser.stripLoaders 'myModule').to.eql 'myModule'

    it 'strips loaders from modules', ->
      expect(ModuleNameParser.stripLoaders 'my-loader!myModule').to.eql 'myModule'

    it 'strips loaders from relative modules', ->
      expect(ModuleNameParser.stripLoaders 'my-loader!./myModule').to.eql './myModule'

    it 'strips all loaders', ->
      expect(ModuleNameParser.stripLoaders 'my-loader!other-loader!myModule').to.eql 'myModule'


  describe 'stripSubpath', ->
    it 'returns modules without subpaths', ->
      expect(ModuleNameParser.stripSubpath 'myModule').to.eql 'myModule'

    it 'returns scoped paths with modules to modules', ->
      expect(ModuleNameParser.stripSubpath '@myOrg/myModule').to.eql '@myOrg/myModule'

    it 'strips subpaths into modules', ->
      expect(ModuleNameParser.stripSubpath 'myModule/subPath').to.eql 'myModule'

    it 'strips subpaths into scoped modules', ->
      expect(ModuleNameParser.stripSubpath '@myOrg/myModule/subPath').to.eql '@myOrg/myModule'
