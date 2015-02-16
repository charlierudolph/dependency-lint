Feature: Executed module

  As a developer needing to configure dependency-lint
  I want it to be able to easily generate a default config file


  Scenario: generate config
    When I run "dependency-lint --generate-config"
    Then now I have the file "dependency-lint.json" with the default config
