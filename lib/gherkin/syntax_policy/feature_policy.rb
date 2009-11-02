require 'gherkin/syntax_policy/feature_state'
require 'gherkin/syntax_policy/scenario_state'
require 'gherkin/syntax_policy/scenario_outline_state'
require 'gherkin/syntax_policy/examples_state'

module Gherkin
  module SyntaxPolicy

    class FeatureSyntaxError < SyntaxError
      attr_reader :event, :line, :expected

      def initialize(event, line, expected)
        @event, @line, @expected = event, line, expected
        super "Syntax error on line #{@line}. Found #{@event} when expecting one of: #{@expected.join(' ')}."
      end
    end
    
    class FeaturePolicy
      attr_writer :raise_on_error
      
      def initialize(listener, raise_on_error=true)
        @listener, @raise_on_error = listener, raise_on_error
        @states = { 
          :feature => FeatureState.new, :scenario => ScenarioState.new, 
          :scenario_outline => ScenarioOutlineState.new, :examples => ExamplesState.new 
        }
        @current = @states[:feature]
      end
            
      def error(args)
        @raise_on_error ? raise(FeatureSyntaxError.new(args.first, args.last, @current.expected)) : @listener.syntax_error(*args)
      end

      def scenario(*args)
        change_state(:scenario)
        dispatch(:scenario, *args)
      end

      def scenario_outline(*args)
        change_state(:scenario_outline)
        dispatch(:scenario_outline, *args)
      end
      
      def examples(*args)
        change_state(:examples)
        dispatch(:examples, *args)
      end

      def method_missing(meth, *args)
        @current.respond_to?(meth) ? dispatch(meth, *args) : super
      end
      
      private 
      
      def change_state(state)
        (@current = @states[state]) if event_allowed?(state)
      end
      
      def dispatch(event, *args)
        event_allowed?(event) ? @listener.send(event, *args) : error([event] + args)
      end
      
      def event_allowed?(event)
        @current.send(event)
      end
    end
  end
end
