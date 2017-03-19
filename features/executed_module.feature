Feature: Executed module

  As a developer with a script that uses an executable exposed a module listed in my package.json
  I want it to be reported as passing


  Background:
    Given I have "myModule" installed
    And the "myModule" module exposes the executable "myExecutable"


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    And I have a script named "install" defined as "myExecutable --opt arg"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR  | SCRIPTS |
      | myModule | <none> | install |


  Scenario: devDependency
    And I have "myModule" listed as a devDependency
    And I have a script named "test" defined as "myExecutable --opt arg"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR  | SCRIPTS |
      | myModule | <none> | test    |
