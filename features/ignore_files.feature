Feature: Unused module

  As a developer requiring a module in an example or fixture file
  I do not want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And I have configured "ignoreFiles" to contain "^examples/"
    And I have a file "examples/server.coffee" which requires "express"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have configured "devFiles" to contain "^spec/"
    And I have configured "ignoreFiles" to contain "^spec/fixtures/"
    And I have a file "spec/fixtures/example.coffee" which requires "notReal"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """
