Feature: Required module with a webpack loader

  As a developer using webpack and dependency-lint
  I want dependency-lint to ignore loaders


  Background:
    Given I have no dependencies listed
    And I have configured "requiredModules.stripLoaders" to be true


  Scenario: local dependency with a loader
    Given I have a file "server.js" which requires "my-loader!./other_file"
    When I run it
    Then it reports no "dependencies"


  Scenario: loading a missing-dependency with a loader
    Given I have a file "server.js" which requires "my-loader!myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR   | FILES     |
      | myModule | missing | server.js |
    And it exits with a non-zero status
