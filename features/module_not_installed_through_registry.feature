Feature: Module not installed through registry

  As a developer with a module in my package.json not installed through a registry
  I don't want any error reported
  So I can install dependencies from other sources

  Background:
    Given I have "myModule @ 1.0.0" installed
    And the "myModule" module exposes the executable "myExecutable"

  Scenario: dependency
    Given I have "myModule @ git+ssh://git@host:myOrganization/myModule.git#1.0.0" listed as a dependency
    And I have a script named "install" defined as "myExecutable --opt arg"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ myModule

      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have "myModule @ git+ssh://git@host:myOrganization/myModule.git#1.0.0" listed as a devDependency
    And I have a script named "test" defined as "myExecutable --opt arg"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ myModule

      ✓ 0 errors
      """
