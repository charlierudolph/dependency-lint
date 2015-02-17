Feature: Required module

  As a developer requiring a module listed in the wrong dependencies in my package.json
  I want it to be reported as needing to be moved to the proper dependencies


  Scenario: dependency listed under devDependencies
    Given I have "express" installed and listed as a devDependency
    And I have a file "server.coffee" which requires "express"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ express (should be dependency)
            used in files:
              server.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency listed under dependencies
    Given I have "chai" installed and listed as a dependency
    And I have configured "devFiles" to contain "_spec.coffee$"
    And I have a file "server_spec.coffee" which requires "chai"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ chai (should be devDependency)
            used in files:
              server_spec.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status
