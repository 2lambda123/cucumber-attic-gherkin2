using Xunit;

namespace Gherkin.Tests.LexerSpecs
{
    public class A_single_feature_single_scenario_single_step : LexerSpec { 
        [Fact] public void should_find_the_feature_scenario_and_step() {
            lexing_input("Feature: Feature Text\n  Scenario: Reading a Scenario\n    Given there is a step\n").
                should_result_in("(root " + 
                                 "(feature 1   Feature  \"Feature Text\" )" +
                                 "(scenario 2   Scenario  \"Reading a Scenario\" )" +
                                 "(step 3 Given \"Given \" \"there is a step\" )" +
                                 "");
        }
    }
}