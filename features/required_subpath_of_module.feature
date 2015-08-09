Feature: Required module: subpath

  As a developer requiring a subpath of a module listed in my package.json
  I want it to be reported as passing


  Background:
    Given I have "myModule" installed


  Scenario: path is stripped from module name
    Given I have "myModule" listed as a dependency
    And I have a file "server.coffee" which requires "myModule/subPath"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ myModule

      ✓ 0 errors
      """


  Scenario: path is stripped from module name
    Given I have "myModule" listed as a devDependency
    And I have a file "server_spec.coffee" which requires "myModule/subPath"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ myModule

      ✓ 0 errors
      """
