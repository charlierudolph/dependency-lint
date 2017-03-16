Feature: Unused module

  As a developer requiring a module in an example or fixture file
  I do not want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And I have configured "requiredModules.files.ignore" to contain "examples/**/*"
    And I have a file "examples/server.js" which requires "myModule"
    When I run "dependency-lint --verbose"
    Then I see the output
      """
      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have configured "requiredModules.files.dev" to contain "spec/**/*.js"
    And I have configured "requiredModules.files.ignore" to contain "spec/fixtures/**/*.js"
    And I have a file "spec/fixtures/example.js" which requires "myModule"
    When I run "dependency-lint --verbose"
    Then I see the output
      """
      ✓ 0 errors
      """
