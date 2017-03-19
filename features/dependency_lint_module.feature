Feature: Self-reporting

  As a developer with dependency-lint listed a devDependency
  I don't want it to be reported as unused
  So that I am not annoyed by an error that can only occur when I'm using it


  Scenario: devDependency
    Given I have "dependency-lint" installed
    And I have "dependency-lint" listed as a devDependency
    When I run it
    Then it reports the "devDependencies":
      | NAME            | ERROR  |
      | dependency-lint | <none> |
