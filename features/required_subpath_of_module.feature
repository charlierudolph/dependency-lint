Feature: Required module: subpath

  As a developer requiring a subpath of a module listed in my package.json
  I want it to be reported as passing


  Scenario: path is stripped from module name
    Given I have "coffee-script" installed
    And I have "coffee-script" listed as a dependency
    And I have a file "server.coffee" which requires "coffee-script/register"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ coffee-script

      ✓ 0 errors
      """


  Scenario: path is stripped from module name
    Given I have "coffee-script" installed
    And I have "coffee-script" listed as a devDependency
    And I have a file "server_spec.coffee" which requires "coffee-script/register"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ coffee-script

      ✓ 0 errors
      """
