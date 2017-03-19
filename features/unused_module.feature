Feature: Unused module

  As a developer not using a module listed in my package.json
  I want it to be reported unused


  Background:
    Given I have "myModule" installed


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR  |
      | myModule | unused |
    And it exits with a non-zero status


  Scenario: dependency (ignored)
    Given I have "myModule" listed as a dependency
    And I have configured "ignoreErrors.unused" to contain "myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR  | ERROR IGNORED |
      | myModule | unused | true          |


  Scenario: devDependency
    Given I have "myModule" listed as a devDependency
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR  |
      | myModule | unused |
    And it exits with a non-zero status


  Scenario: devDependency (ignored)
    Given I have "myModule" listed as a devDependency
    And I have configured "ignoreErrors.unused" to contain "myModule"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR  | ERROR IGNORED |
      | myModule | unused | true          |
