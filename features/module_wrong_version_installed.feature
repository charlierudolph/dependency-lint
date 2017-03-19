Feature: Module wrong version installed

  As a developer with a module in my package.json and a different version installed
  I want an error to be reported

  Background:
    Given I have "myModule @ 1.0.0" installed

  Scenario: dependency
    Given I have "myModule @ ^2.0.0" listed as a dependency
    When I run it
    Then I see the error
      """
      The following modules listed in your `package.json` have issues:
        myModule (installed: 1.0.0, listed: ^2.0.0)
      All modules need to be installed with the correct semantic version
      to properly check for the usage of a module's executables.
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have "myModule @ ^2.0.0" listed as a devDependency
    When I run it
    Then I see the error
      """
      The following modules listed in your `package.json` have issues:
        myModule (installed: 1.0.0, listed: ^2.0.0)
      All modules need to be installed with the correct semantic version
      to properly check for the usage of a module's executables.
      """
    And it exits with a non-zero status
