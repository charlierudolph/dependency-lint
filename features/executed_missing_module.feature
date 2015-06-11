Feature: Executed module: missing

  As a developer with a script that executes a module not listed in my package.json
  I want it to be reported as missing


  Scenario: dependency
    Given I have no dependencies listed
    And the "coffee-script" module exposes the executable "coffee"
    And I have a script named "install" defined as "coffee --compile --output lib/ src/"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✖ coffee-script (missing)
            used in scripts:
              install

      ✖ 1 error
      """
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have no devDependencies listed
    And the "mycha" module exposes the executable "mycha"
    And I have a script named "test" defined as "mycha run --reporter spec"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✖ mycha (missing)
            used in scripts:
              test

      ✖ 1 error
      """
    And it exits with a non-zero status
