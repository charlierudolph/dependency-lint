Feature: Generating config

  As a developer needing to configure dependency-lint
  I want it to be able to easily generate a default config file


  Scenario: generate coffee config
    When I run "dependency-lint --generate-config coffee"
    Then now I have the file "dependency-lint.coffee" with the default coffee config


  Scenario: generate cson config
    When I run "dependency-lint --generate-config cson"
    Then now I have the file "dependency-lint.cson" with the default cson config


  Scenario: generate js config
    When I run "dependency-lint --generate-config js"
    Then now I have the file "dependency-lint.js" with the default js config


  Scenario: generate json config
    When I run "dependency-lint --generate-config json"
    Then now I have the file "dependency-lint.json" with the default json config


  Scenario: generate yaml config
    When I run "dependency-lint --generate-config yaml"
    Then now I have the file "dependency-lint.yaml" with the default yaml config


  Scenario: generate yml config
    When I run "dependency-lint --generate-config yml"
    Then now I have the file "dependency-lint.yml" with the default yml config
