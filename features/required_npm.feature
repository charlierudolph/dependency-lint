Feature: Required module: npm

  As a developer requiring npm that is locally installed
  I want it to be reported as globally installed


  Scenario: dependency not listed
    Given I have no dependencies listed
    And I have a file "server.coffee" which requires "npm"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """


  Scenario: dependency listed
    Given I have "npm" installed and listed as a dependency
    And I have a file "server.coffee" which requires "npm"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ npm (global - remove from package.json)

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency not listed
    Given I have no dependencies listed
    And I have configured "devFiles" to contain "_spec.coffee$"
    And I have a file "server_spec.coffee" which requires "npm"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """


  Scenario: devDependency listed
    Given I have "npm" installed and listed as a dependency
    And I have configured "devFiles" to contain "_spec.coffee$"
    And I have a file "server_spec.coffee" which requires "npm"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ npm (global - remove from package.json)

      ✖ 1 error
      """
    And it exits with a non-zero status
