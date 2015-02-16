Feature: Required module: built in

  As a developer requiring a built in module
  I do not want it to be reported a missing dependency or devDependency


  Scenario: dependency
    Given I have no dependencies listed
    And I have a file "server.coffee" which requires "http"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """


  Scenario: devDependency
    Given I have no dependencies listed
    And I have configured "devFiles" to contain "_spec.coffee$"
    And I have a file "server_spec.coffee" which requires "fs"
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """
