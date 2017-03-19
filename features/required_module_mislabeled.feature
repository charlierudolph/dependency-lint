Feature: Required module: mislabled

  As a developer requiring a module that is listed incorrectly in my package.json
  I want it to be reported as needing to be moved to the proper place


  Background:
    Given I have "myModule" installed


  Scenario: dependency listed under devDependencies
    Given I have "myModule" listed as a devDependency
    And I have a file "server.js" which requires "myModule"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR                | FILES     |
      | myModule | should be dependency | server.js |
    And it exits with a non-zero status


  Scenario: dependency listed under devDependencies (ignored)
    Given I have "myModule" listed as a devDependency
    And I have a file "server.js" which requires "myModule"
    And I have configured "ignoreErrors.shouldBeDependency" to contain "myModule"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR                | ERROR IGNORED | FILES     |
      | myModule | should be dependency | true          | server.js |


  Scenario: dependency listed under dependencies and devDependencies
    Given I have "myModule" listed as a dependency
    And I have "myModule" listed as a devDependency
    And I have a file "server.js" which requires "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR  | FILES     |
      | myModule | <none> | server.js |
    Then it reports the "devDependencies":
      | NAME     | ERROR                | FILES     |
      | myModule | should be dependency | server.js |
    And it exits with a non-zero status


  Scenario: devDependency listed under dependencies
    Given I have "myModule" listed as a dependency
    And I have a file "server_spec.js" which requires "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR                   | FILES          |
      | myModule | should be devDependency | server_spec.js |
    And it exits with a non-zero status


  Scenario: devDependency listed under dependencies (ignored)
    Given I have "myModule" listed as a dependency
    And I have a file "server_spec.js" which requires "myModule"
    And I have configured "ignoreErrors.shouldBeDevDependency" to contain "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR                   | ERROR IGNORED | FILES          |
      | myModule | should be devDependency | true          | server_spec.js |


  Scenario: devDependency listed under dependencies and devDependencies
    Given I have "myModule" listed as a dependency
    And I have "myModule" listed as a devDependency
    And I have a file "server_spec.js" which requires "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR                   | FILES          |
      | myModule | should be devDependency | server_spec.js |
    Then it reports the "devDependencies":
      | NAME     | ERROR  | FILES          |
      | myModule | <none> | server_spec.js |
    And it exits with a non-zero status
