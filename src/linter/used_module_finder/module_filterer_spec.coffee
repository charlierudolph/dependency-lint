ModuleFilterer = require './module_filterer'


describe 'ModuleFilterer', ->

  describe 'filterExecutedModules', ->
    it 'removes global modules', ->
      result = ModuleFilterer.filterExecutedModules ['npm']
      expect(result).to.eql []


  describe 'filterRequiredModules', ->
    it 'removes relative requires', ->
      result = ModuleFilterer.filterRequiredModules ['./helper']
      expect(result).to.eql []

    it 'removes built in modules', ->
      result = ModuleFilterer.filterRequiredModules ['fs']
      expect(result).to.eql []

    it 'removes paths into modules', ->
      result = ModuleFilterer.filterRequiredModules ['myModule/subPath']
      expect(result).to.eql ['myModule']

    it 'removes paths into scoped modules', ->
      result = ModuleFilterer.filterRequiredModules ['@myOrganization/myModule/nested']
      expect(result).to.eql ['@myOrganization/myModule']
