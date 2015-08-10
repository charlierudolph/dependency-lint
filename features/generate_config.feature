Feature: Generating config

  As a developer needing to configure dependency-lint
  I want it to be able to easily generate a default config file


  Scenario Outline: generate config
    When I run "dependency-lint --generate-config <EXT>"
    Then now I have the file "dependency-lint.<EXT>" with the default config
    When I run "dependency-lint"
    Then I see the output
      """
      ✓ 0 errors
      """

    Examples:
      | EXT    |
      | coffee |
      | cson   |
      | js     |
      | json   |
      | yaml   |
      | yml    |
