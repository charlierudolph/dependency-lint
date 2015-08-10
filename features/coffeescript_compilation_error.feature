Feature: Coffeescript compilation error

  As a developer with an error in my coffeescript file
  I want an appropriate error message


  Scenario: coffeescript compilation error
    Given I have a file "server.coffee" with a coffeescript compilation error
    When I run "dependency-lint"
    Then I see the error
      """
      server.coffee
      """
    And it exits with a non-zero status
