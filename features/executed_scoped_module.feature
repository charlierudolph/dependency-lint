Feature: Executed scoped module

  As a developer with a script that uses an executable exposed by a scoped module listed in my package.json
  I want it to be reported as passing


  Background:
    Given I have "@myOrganization/myModule" installed
    And the "@myOrganization/myModule" module exposes the executable "myExecutable"


  Scenario: dependency
    Given I have "@myOrganization/myModule" listed as a dependency
    And I have a script named "install" defined as "myExecutable --opt arg"
    When I run it
    Then it reports the "dependencies":
      | NAME                     | ERROR  | SCRIPTS |
      | @myOrganization/myModule | <none> | install |


  Scenario: devDependency
    Given I have "@myOrganization/myModule" listed as a devDependency
    And I have a script named "test" defined as "myExecutable --opt arg"
    When I run it
    Then it reports the "devDependencies":
      | NAME                     | ERROR  | SCRIPTS |
      | @myOrganization/myModule | <none> | test    |
