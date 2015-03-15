Feature: Unused module

  As a developer not using a module listed in my package.json
  I want it to be reported unused


  Scenario: dependency
    Given I have "express" installed and listed as a dependency
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ express (unused)

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have "chai" installed and listed as a devDependency
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ chai (unused)

      ✖ 1 error
      """
    And it exits with a non-zero status
