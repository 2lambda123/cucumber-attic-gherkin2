require 'gherkin/syntax_policy/feature_policy_state'

module Gherkin
  module SyntaxPolicy
    class ScenarioState < FeaturePolicyState
      def scenario
        @step_allowed = true
        true
      end
      
      def scenario_outline
        true
      end
    end
  end
end
