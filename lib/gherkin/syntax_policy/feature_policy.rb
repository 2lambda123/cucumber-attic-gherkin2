require 'gherkin/syntax_policy/feature_state'
require 'gherkin/syntax_policy/scenario_state'
require 'gherkin/syntax_policy/scenario_outline_state'

module Gherkin
  module SyntaxPolicy

    class FeatureSyntaxError < SyntaxError
      attr_reader :keyword, :content, :line
      
      def initialize(event, keyword, content, line, *args)
        @event, @keyword, @content, @line = event, keyword, content, line
        super "Syntax error on line #{@line}: '#{@keyword}: #{@content}'."
      end
    end
    
    class FeaturePolicy
      attr_writer :raise_on_error
      
      def initialize(listener, raise_on_error=true)
        @listener, @raise_on_error = listener, raise_on_error
        @states = { :feature => FeatureState.new, :scenario => ScenarioState.new, :scenario_outline => ScenarioOutlineState.new }
        @current = @states[:feature]
      end
            
      def error(args)
        @raise_on_error ? raise(FeatureSyntaxError.new(*args)) : @listener.syntax_error(*args)
      end

      def scenario(*args)
        change_state(:scenario)
        dispatch(:scenario, *args)
      end

      def scenario_outline(*args)
        change_state(:scenario_outline)
        dispatch(:scenario_outline, *args)
      end

      def method_missing(meth, *args)
        @current.respond_to?(meth) ? dispatch(meth, *args) : super
      end
      
      private 
      
      def change_state(state)
        if @current.send(state)
          @current = @states[state]
        end
      end
      
      def dispatch(event, *args)
        if @current.send(event)
          @listener.send(event, *args)
        else
          error([event] + args)
        end
      end
    end
  end
end
