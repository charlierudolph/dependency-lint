Feature: Required module: built in

  As a developer requiring a built in module
  I do not want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And I have a file "server.js" which requires "http"
    When I run it
    Then it reports no "dependencies"


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have a file "server_spec.js" which requires "fs"
    When I run it
    Then it reports no "dependencies"
