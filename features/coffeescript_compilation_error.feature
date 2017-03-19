Feature: Coffeescript compilation error

  As a developer with an error in my coffeescript file
  I want an appropriate error message

  Background:
    Given I have configured "requiredModules.files.root" to be "**/*.coffee"
    And I have configured "requiredModules.transpilers" to contain
      | EXTENSION | MODULE        |
      | .coffee   | coffee-script |


  Scenario: coffeescript compilation error
    Given I have a file "server.coffee" with a coffeescript compilation error
    When I run it
    Then I see the error
      """
      server.coffee
      """
    And it exits with a non-zero status
