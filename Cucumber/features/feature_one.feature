@feature_one
@spec_one @tag_one
Feature: This is the first feature

  @scenario_outline
  # @tag
  @tags_one @tagScenarioOne
  Scenario Outline: Verify date (scenario outline)
    Given current date
    When your date is <year>, <month>, <week>, <day>
    Then the result should be '<result>'
    @smoke
    Examples:
      | year | month | week | day | result |
      | 2021 | 07    | 3    | 01  | OK     |
    @smoke
    @regression
    Examples:
      | year | month | week | day | result |
      | 2015 | 04    | 2    | 17  | NOT_OK |
    @secondary
    @regression
    Examples:
      | year | month | week | day | result |
      | 2020 | 08    | 5    | 07  | NOT_OK |


  # COMMENTED Scenario
  # @scenario
  # @tag
  # @tags_two @tagScenarioTwo
  # Scenario: Verify date (scenario)
  #   Given current date
  #   When your date is 2019, 06, 02, 12
  #   Then the result should be 'OK'

  @scenario
  # @tag
  @tags_two @tagScenarioTwo
  Scenario: Verify date (scenario)
    Given current date
    When your date is 2019, 06, 02, 12
    Then the result should be 'OK'
