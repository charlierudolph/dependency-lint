Feature: Required module: subpath

  As a developer requiring a subpath of a module listed in my package.json
  I want it to be reported as passing


  Background:
    Given I have "myModule" installed


  Scenario: path is stripped from module name
    Given I have "myModule" listed as a dependency
    And I have a file "server.js" which requires "myModule/subPath"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR  | FILES     |
      | myModule | <none> | server.js |


  Scenario: path is stripped from module name
    Given I have "myModule" listed as a devDependency
    And I have a file "server_spec.js" which requires "myModule/subPath"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR  | FILES          |
      | myModule | <none> | server_spec.js |
