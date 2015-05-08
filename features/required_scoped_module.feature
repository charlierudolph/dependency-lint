Feature: Required module: scoped

  As a developer requiring a scoped module listed in my package.json
  I want it to be reported as passing


  Scenario: path is stripped from module name
    Given I have "@myorg/mypackage" installed and listed as a dependency
    And I have a file "server.coffee" which requires "@myorg/mypackage"
    When I run "dependency-lint"
    Then I see the output
      """
      dependencies:
        ✓ @myorg/mypackage

      ✓ 0 errors
      """


  Scenario: path is stripped from module name
    Given I have "@myorg/mypackage" installed and listed as a devDependency
    And I have configured "devFiles" to contain "_spec.coffee$"
    And I have a file "server_spec.coffee" which requires "@myorg/mypackage"
    When I run "dependency-lint"
    Then I see the output
      """
      devDependencies:
        ✓ @myorg/mypackage

      ✓ 0 errors
      """
