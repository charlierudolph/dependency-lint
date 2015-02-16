Feature: Unused module

  As a developer with a module listed in my package.json but not referenced anywhere
  I want it to be able to able to ignore it when I know it is used


  Scenario: dependency
    Given I have "jade" installed and listed as a dependency
    And I have configured "ignoreUnused" to contain "jade"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        - jade (unused but ignored)

      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have "coffeelint-variable-scope" installed and listed as a devDependency
    And I have configured "ignoreUnused" to contain "^coffeelint-"
    When I run "dependency-lint"
    Then I see the output
      """
        devDependencies:
          - coffeelint-variable-scope (unused but ignored)

      ✓ 0 errors
      """
