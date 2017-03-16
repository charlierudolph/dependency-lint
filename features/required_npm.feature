Feature: Required module: npm

  As a developer requiring npm that is locally installed
  I want it to be reported like a normal module as global modules cannot be required


  Scenario: dependency not listed
    Given I have no dependencies listed
    And I have a file "server.js" which requires "npm"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ npm (missing)
          used in files:
            server.js

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: dependency listed
    Given I have "npm" installed
    And I have "npm" listed as a dependency
    And I have a file "server.js" which requires "npm"
    When I run "dependency-lint --verbose"
    Then I see the output
      """
      dependencies:
        ✓ npm

      ✓ 0 errors
      """


  Scenario: devDependency not listed
    Given I have no devDependencies listed
    And I have a file "server_spec.js" which requires "npm"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ npm (missing)
          used in files:
            server_spec.js

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency listed
    Given I have "npm" installed
    And I have "npm" listed as a devDependency
    And I have a file "server_spec.js" which requires "npm"
    When I run "dependency-lint --verbose"
    Then I see the output
      """
      devDependencies:
        ✓ npm

      ✓ 0 errors
      """
