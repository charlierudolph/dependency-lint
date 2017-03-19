Feature: Required module: missing

  As a developer requiring a module that is not listed in my package.json
  I want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And I have a file "server.js" which requires "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR   | FILES     |
      | myModule | missing | server.js |
    And it exits with a non-zero status


  Scenario: dependency (ignored)
    Given I have no dependencies listed
    And I have a file "server.js" which requires "myModule"
    And I have configured "ignoreErrors.missing" to contain "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR   | ERROR IGNORED | FILES     |
      | myModule | missing | true          | server.js |


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have a file "server_spec.js" which requires "myModule"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR   | FILES          |
      | myModule | missing | server_spec.js |
    And it exits with a non-zero status


  Scenario: devDependency (ignored)
    Given I have no devDependencies listed
    And I have a file "server_spec.js" which requires "myModule"
    And I have configured "ignoreErrors.missing" to contain "myModule"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR   | ERROR IGNORED | FILES          |
      | myModule | missing | true          | server_spec.js |
