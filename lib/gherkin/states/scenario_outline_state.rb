require 'gherkin/states/state'

module Gherkin
  module States
    class ScenarioOutlineState < State
      def initialize
        @examples = false
        super
      end

      def scenario
        true
      end
      
      def scenario_outline
        @step = true
      end
      
      def examples
        @examples
      end

      def tag
        @examples = false
        super
      end

      def step
        if super
          @examples = true
        end
      end
    end
  end
end
