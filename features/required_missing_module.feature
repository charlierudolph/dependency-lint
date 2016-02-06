Feature: Required module: missing

  As a developer requiring a module that is not listed in my package.json
  I want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And I have a file "server.js" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ myModule (missing)
            used in files:
              server.js

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have a file "server_spec.js" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ myModule (missing)
            used in files:
              server_spec.js

      ✖ 1 error
      """
    And it exits with a non-zero status
