Feature: Required module with a webpack loader

  As a developer using webpack and dependency-lint
  I want dependency-lint to ignore loaders


  Background:
    Given I have no dependencies listed
    And I have configured "stripLoaders" to be true


  Scenario: local dependency with a loader
    Given I have a file "server.coffee" which requires "my-loader!./other_file"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """


  Scenario: loading a missing-dependency with a loader
    Given I have a file "server.coffee" which requires "my-loader!myModule"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ myModule (missing)
            used in files:
              server.coffee

      ✖ 1 error
      """
    And it exits with a non-zero status
