Feature: Required module

  As a developer requiring a module listed in my package.json
  I want it to be reported as passing


  Background:
    Given I have "myModule" installed


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    And I have a file "server.js" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ myModule

      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have "myModule" listed as a devDependency
    And I have a file "server_spec.js" which requires "myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ myModule

      ✓ 0 errors
      """
