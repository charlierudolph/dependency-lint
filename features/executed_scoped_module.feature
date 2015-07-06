Feature: Executed scoped module

  As a developer with a script that uses an executable exposed by a scoped module listed in my package.json
  I want it to be reported as passing


  Scenario: dependency
    Given I have "@myorg/mypackage" installed
    And I have "@myorg/mypackage" listed as a dependency
    And the "@myorg/mypackage" module exposes the executable "myexecutable"
    And I have a script named "install" defined as "myexecutable --opt path/to/file"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ @myorg/mypackage

      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have "@myorg/mypackage" installed
    And I have "@myorg/mypackage" listed as a devDependency
    And the "@myorg/mypackage" module exposes the executable "myexecutable"
    And I have a script named "test" defined as "myexecutable --opt path/to/file"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ @myorg/mypackage

      ✓ 0 errors
      """
