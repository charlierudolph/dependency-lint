Feature: Executed module: npm

  As a developer with a script that executes npm that is locally installed
  I want it to be reported as unused because it is globally installed


  Background:
    Given I have "npm" installed
    And the "npm" module exposes the executable "npm"


  Scenario: dependency not listed
    Given I have no dependencies listed
    And I have a script named "install" defined as "npm run build"
    When I run it
    Then it reports no "dependencies"


  Scenario: dependency listed
    Given I have "npm" listed as a dependency
    And I have a script named "install" defined as "npm run build"
    When I run it
    Then it reports the "dependencies":
      | NAME | ERROR  |
      | npm  | unused |
    And it exits with a non-zero status


  Scenario: devDependency
    Given I have no devDependencies listed
    And I have a script named "pretest" defined as "npm run lint"
    When I run it
    Then it reports no "devDependencies"


  Scenario: devDependency listed
    Given I have "npm" listed as a devDependency
    And I have a script named "pretest" defined as "npm run lint"
    When I run it
    Then it reports the "devDependencies":
      | NAME | ERROR  |
      | npm  | unused |
    And it exits with a non-zero status
