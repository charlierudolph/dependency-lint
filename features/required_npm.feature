Feature: Required module: npm

  As a developer requiring npm that is locally installed
  I want it to be reported like a normal module as global modules cannot be required


  Scenario: dependency not listed
    Given I have no dependencies listed
    And I have a file "server.js" which requires "npm"
    When I run it
    Then it reports the "dependencies":
      | NAME | ERROR   | FILES     |
      | npm  | missing | server.js |
    And it exits with a non-zero status


  Scenario: dependency listed
    Given I have "npm" installed
    And I have "npm" listed as a dependency
    And I have a file "server.js" which requires "npm"
    When I run it
    Then it reports the "dependencies":
      | NAME | ERROR  | FILES     |
      | npm  | <none> | server.js |


  Scenario: devDependency not listed
    Given I have no devDependencies listed
    And I have a file "server_spec.js" which requires "npm"
    When I run it
    Then it reports the "devDependencies":
      | NAME | ERROR   | FILES          |
      | npm  | missing | server_spec.js |
    And it exits with a non-zero status


  Scenario: devDependency listed
    Given I have "npm" installed
    And I have "npm" listed as a devDependency
    And I have a file "server_spec.js" which requires "npm"
    When I run it
    Then it reports the "devDependencies":
      | NAME | ERROR  | FILES          |
      | npm  | <none> | server_spec.js |
