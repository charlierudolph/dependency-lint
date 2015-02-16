Feature: Executed module

  As a developer with a script that executes a module listed in my package.json
  I want it to be reported as passing


  Scenario: dependency
    Given I have "coffee-script" installed and listed as a dependency
    And the "coffee-script" module exposes the executable "coffee"
    And I have a script named "install" defined as "coffee --compile --output lib/ src/"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ coffee-script

      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have "mycha" installed and listed as a devDependency
    And the "mycha" module exposes the executable "mycha"
    And I have configured "devScripts" to contain "test"
    And I have a script named "test" defined as "mycha run --reporter spec"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ mycha

      ✓ 0 errors
      """
