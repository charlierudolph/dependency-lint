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
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ myModule

      ✓ 0 errors
      """


  Scenario: devDependency
    And I have "myModule" listed as a devDependency
    And I have configured "executedModules.shellScripts.dev" to contain "bin/test"
    And I have a file "bin/test" with the content:
      """
      myExecutable --opt arg
      """
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ myModule

      ✓ 0 errors
      """
