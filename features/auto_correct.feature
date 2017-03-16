Feature: auto-correct

  As a developer with errors caught by dependency-lint
  I want a way to automatically fix as many errors as possible


  Background:
    Given I have "myModule" installed


  Scenario: dependency listed under devDependencies
    Given I have "myModule" listed as a devDependency
    And I have a file "server.js" which requires "myModule"
    When I run "dependency-lint --auto-correct"
    Then I see the output
      """
      devDependencies:
        ✖ myModule (should be dependency - fixed)
            used in files:
              server.js

      ✖ 1 error
      """
    And it exits with a non-zero status
    And now I no longer have "myModule" listed as a devDependency
    And now I have "myModule" listed as a dependency


  Scenario: devDependency listed under dependencies
    Given I have "myModule" listed as a dependencies
    And I have a file "server_spec.js" which requires "myModule"
    When I run "dependency-lint --auto-correct"
    Then I see the output
      """
      dependencies:
        ✖ myModule (should be devDependency - fixed)
            used in files:
              server_spec.js

      ✖ 1 error
      """
    And it exits with a non-zero status
    And now I no longer have "myModule" listed as a dependency
    And now I have "myModule" listed as a devDependency


  Scenario: unused dependency
    Given I have "myModule" listed as a dependency
    When I run "dependency-lint --auto-correct"
    Then I see the output
      """
      dependencies:
        ✖ myModule (unused - fixed)

      ✖ 1 error
      """
    And it exits with a non-zero status
    And now I no longer have "myModule" listed as a dependency


  Scenario: unused devDependency
    Given I have "myModule" listed as a devDependency
    When I run "dependency-lint --auto-correct"
    Then I see the output
      """
      devDependencies:
        ✖ myModule (unused - fixed)

      ✖ 1 error
      """
    And it exits with a non-zero status
    And now I no longer have "myModule" listed as a devDependency


  Scenario: unused dependency - ignored
    Given I have "myModule" listed as a dependency
    And I have configured "ignoreErrors.unused" to contain "myModule"
    When I run "dependency-lint --auto-correct --verbose"
    Then I see the output
      """
      dependencies:
        - myModule (unused - ignored)

      ✓ 0 errors
      """
    And I still have "myModule" listed as a dependency
