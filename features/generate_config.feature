Feature: Generating config

  As a developer needing to configure dependency-lint
  I want it to be able to easily generate a default config file


  Scenario: generate config
    When I run it with --generate-config
    Then now I have the file "dependency-lint.yml" with the default config
    And "dependency-lint.yml" contains
      """
      # See https://github.com/charlierudolph/dependency-lint/blob/v{{version}}/docs/configuration.md
      # for a detailed explanation of the options
      """
    When I run it
    Then it reports no "dependencies"
