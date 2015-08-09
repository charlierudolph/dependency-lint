Feature: Required module: mislabled

  As a developer requiring a module that is listed incorrectly in my package.json
  I want it to be reported as needing to be moved to the proper place


  Background:
    Given I have "myModule" installed


  Scenario: dependency listed under devDependencies
    Given I have "myModule" listed as a devDependency
    And I have a file "server.coffee" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ myModule (should be dependency)
            used in files:
              server.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: dependency listed under dependencies and devDependencies
    Given I have "myModule" listed as a dependency
    And I have "myModule" listed as a devDependency
    And I have a file "server.coffee" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ myModule

      devDependencies:
        ✖ myModule (should be dependency)
            used in files:
              server.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency listed under dependencies
    Given I have "myModule" listed as a dependency
    And I have a file "server_spec.coffee" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ myModule (should be devDependency)
            used in files:
              server_spec.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency listed under dependencies and devDependencies
    Given I have "myModule" listed as a dependency
    And I have "myModule" listed as a devDependency
    And I have a file "server_spec.coffee" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ myModule (should be devDependency)
            used in files:
              server_spec.coffee

      devDependencies:
        ✓ myModule

      ✖ 1 error
      """
    And it exits with a non-zero status
