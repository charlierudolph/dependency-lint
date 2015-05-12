Feature: Module not installed

  As a developer with a module in my package.json that is not installed
  I want it an error to be reported


  Scenario: dependency
    Given I have "coffee-script" listed as a dependency
    When I run "dependency-lint"
    Then I see the error
      """
      The following modules are listed in your `package.json` but are not installed.
        coffee-script
      All modules need to be installed to properly check for the usage of a module's executables.
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have "mycha" listed as a devDependency
    When I run "dependency-lint"
    Then I see the error
      """
      The following modules are listed in your `package.json` but are not installed.
        mycha
      All modules need to be installed to properly check for the usage of a module's executables.
      """
    And it exits with a non-zero status
