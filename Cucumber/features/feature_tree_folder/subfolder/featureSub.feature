@feature_sub
@spec_three @tag_three
Feature: This is the second feature

  @scenario_outline
  # @tag
  @tags_scen_one @tagScenarioTwo
  Scenario Outline: Verify date lower than today (scenario outline)
    Given current date
    When your date is <year>, <month>, <day>
    Then the result should be '<result>'
    @smoke
    Examples:
      | year | month | day | result      |
      | 2051 | 07    | 01  | not lower   |
      | 2015 | 04    | 17  | lower       |
    @secondary
    @regression
    Examples:
      | year | month | day | result    |
      | 2020 | 08    | 07  | not lower |

  @scenario
  # @tag
  @tags_scen_two @tagScenarioTwo
  Scenario: Verify date lower than today (scenario)
    Given current date
    When your date is 2010, 06, 02, 12
    Then the result should be 'lower'
