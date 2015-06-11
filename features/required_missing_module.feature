Feature: Required module: missing

  As a developer requiring a module that is not listed in my package.json
  I want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And I have a file "server.coffee" which requires "express"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ express (missing)
            used in files:
              server.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have no dependencies listed
    And I have a file "server_spec.coffee" which requires "chai"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ chai (missing)
            used in files:
              server_spec.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status
