Feature: Required module: scoped

  As a developer requiring a scoped module listed in my package.json
  I want it to be reported as passing


  Background:
    Given I have "@myOrganization/myModule" installed


  Scenario: dependency
    Given I have "@myOrganization/myModule" listed as a dependency
    And I have a file "server.js" which requires "@myOrganization/myModule"
    When I run it
    Then it reports the "dependencies":
      | NAME                     | ERROR  | FILES     |
      | @myOrganization/myModule | <none> | server.js |


  Scenario: devDependency
    Given I have "@myOrganization/myModule" listed as a devDependency
    And I have a file "server_spec.js" which requires "@myOrganization/myModule"
    When I run it
    Then it reports the "devDependencies":
      | NAME                     | ERROR  | FILES          |
      | @myOrganization/myModule | <none> | server_spec.js |
