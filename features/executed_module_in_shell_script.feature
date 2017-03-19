Feature: Executed module

  As a developer with a shell script that uses an executable exposed a module
  I want it to be reported as passing


  Background:
    Given I have "myModule" installed
    And the "myModule" module exposes the executable "myExecutable"
    And I have configured "executedModules.shellScripts.root" to be "bin/*"


  Scenario: dependency
    Given I have "myModule" listed as a dependency
    And I have a file "bin/run" with the content:
      """
      myExecutable --opt arg
      """
    When I run it
    Then it reports the "dependencies":
      | NAME     | ERROR  | FILES   |
      | myModule | <none> | bin/run |


  Scenario: devDependency
    And I have "myModule" listed as a devDependency
    And I have configured "executedModules.shellScripts.dev" to contain "bin/test"
    And I have a file "bin/test" with the content:
      """
      myExecutable --opt arg
      """
    When I run it
    Then it reports the "devDependencies":
      | NAME     | ERROR  | FILES    |
      | myModule | <none> | bin/test |


  Scenario: respects word boundaries
    Given I have a file "bin/run" with the content:
      """
      othermyExecutable --opt arg
      """
    When I run it
    Then it reports no "dependencies"
