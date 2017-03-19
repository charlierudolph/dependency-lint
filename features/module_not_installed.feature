Feature: Module not installed

  As a developer with a module in my package.json that is not installed
  I want it an error to be reported


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    When I run it
    Then I see the error
      """
      The following modules listed in your `package.json` have issues:
        myModule (not installed)
      All modules need to be installed with the correct semantic version
      to properly check for the usage of a module's executables.
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have "myModule" listed as a devDependency
    When I run it
    Then I see the error
      """
      The following modules listed in your `package.json` have issues:
        myModule (not installed)
      All modules need to be installed with the correct semantic version
      to properly check for the usage of a module's executables.
      """
    And it exits with a non-zero status
