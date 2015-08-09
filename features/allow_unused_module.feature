Feature: Unused module

  As a developer with a module listed in my package.json but not referenced anywhere
  I want it to be able to allow it to be unused


  Background:
    Given I have "myModule" installed
    And I have configured "allowUnused" to contain "myModule"


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        - myModule (unused - allowed)

      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have "myModule" listed as a devDependency
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        - myModule (unused - allowed)

      ✓ 0 errors
      """
