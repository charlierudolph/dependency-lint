Feature: Module not installed

  As a developer with a module in my package.json that is not installed
  I want it an error to be reported


  Scenario: dependency
    Given I have "coffee-script" listed as a dependency
    When I run "dependency-lint"
    Then I see the error
      """
      You have uninstalled modules listed in your package. Please run `npm install`.
      dependency-lint needs all modules to be installed in order to search module executables.
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have "mycha" listed as a devDependency
    When I run "dependency-lint"
    Then I see the error
      """
      You have uninstalled modules listed in your package. Please run `npm install`.
      dependency-lint needs all modules to be installed in order to search module executables.
      """
    And it exits with a non-zero status
