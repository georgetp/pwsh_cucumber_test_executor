@feature_two
@spec_two @tag_two
Feature: This is the second feature

  @scenario_outline
  # @tag
  @tags_one @tagScenarioTwo
  Scenario Outline: Verify date greater than today (scenario outline)
    Given current date
    When your date is <year>, <month>, <day>
    Then the result should be '<result>'
    @smoke
    Examples:
      | year | month | day | result      |
      | 2051 | 07    | 01  | greater     |
    @smoke
    @not_greater
    Examples:
      | year | month | day | result      |
      | 2015 | 04    | 17  | not greater |
    @secondary
    @regression
    Examples:
      | year | month | day | result      |
      | 2020 | 08    | 07  | not greater |

  @scenario
  # @tag
  @tags_two @tagScenarioTwo
  Scenario: Verify date greater than today (scenario)
    Given current date
    When your date is 2010, 06, 02, 12
    Then the result should be 'not greater'
