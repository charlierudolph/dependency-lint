Feature: Executed module: missing

  As a developer with a script that executes a module not listed in my package.json
  I want it to be reported as missing


  Background:
    Given I have "myModule" installed
    And the "myModule" module exposes the executable "myExecutable"


  Scenario: dependency
    Given I have no dependencies listed
    And I have a script named "install" defined as "myExecutable --opt arg"
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR   | SCRIPTS |
      | myModule | missing | install |
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have a script named "test" defined as "myExecutable --opt arg"
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR   | SCRIPTS |
      | myModule | missing | test    |
    And it exits with a non-zero status
