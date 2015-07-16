ModuleFilterer = require './module_filterer'


describe 'ModuleFilterer', ->
  beforeEach ->
    @moduleFilterer = new ModuleFilterer


  describe 'filterExecutedModules', ->
    it 'removes global modules', ->
      result = @moduleFilterer.filterExecutedModules ['npm']
      expect(result).to.eql []


  describe 'filterRequiredModules', ->
    it 'removes relative requires', ->
      result = @moduleFilterer.filterRequiredModules ['./relative']
      expect(result).to.eql []

    it 'removes built in modules', ->
      result = @moduleFilterer.filterRequiredModules ['fs']
      expect(result).to.eql []

    it 'removes paths into modules', ->
      result = @moduleFilterer.filterRequiredModules ['coffee-script/register']
      expect(result).to.eql ['coffee-script']

    it 'removes paths into scoped modules', ->
      result = @moduleFilterer.filterRequiredModules ['@myorg/mypackage/nested']
      expect(result).to.eql ['@myorg/mypackage']
