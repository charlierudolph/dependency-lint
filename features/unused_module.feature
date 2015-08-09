Feature: Unused module

  As a developer not using a module listed in my package.json
  I want it to be reported unused


  Background:
    Given I have "myModule" installed


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ myModule (unused)

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have "myModule" listed as a devDependency
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ myModule (unused)

      ✖ 1 error
      """
    And it exits with a non-zero status
