Feature: Minimaal formatter

  Only prints modules with errors


  Background:
    Given I have "myModule" installed


  Scenario: without error
    Given I have "myModule" listed as a dependency
    And I have a file "server.js" which requires "myModule"
    When I run it with the "minimal" format
    Then I see no output


  Scenario: with error
    And I have a file "server.js" which requires "myModule"
    When I run it with the "minimal" format
    Then I see the output
      """
      dependencies:
        ✖ myModule (missing)
            used in files:
              server.js

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: with error ignored
    And I have a file "server.js" which requires "myModule"
    And I have configured "ignoreErrors.missing" to contain "myModule"
    When I run it with the "minimal" format
    Then I see no output


  Scenario: with error fixed
    Given I have "myModule" listed as a dependency
    When I run it with --auto-correct and the "minimal" format
    Then I see the output
      """
      dependencies:
        ✖ myModule (unused - fixed)

      ✖ 1 error
      """
    And it exits with a non-zero status
