module Gherkin
  module Tools
    class Sexp < Array
      def initialize(*args)
        super
        self[1] = self[1].to_a if event == :row # Special JRuby handling
      end

      def line_match?(lines)
        lines.include?(line)
      end

      def name_match?(name_regexen)
        return false unless [:feature, :scenario, :scenario_outline, :examples].include?(event)
        name_regexen.detect{|name_regex| name =~ name_regex}
      end

      def event
        self[0]
      end
      
      def args
        self[1..-1]
      end

      def replay(listener)
        listener.__send__(event, *args)
      end

    private

      def name
        self[2]
      end

      def line
        self[-1]
      end

    end
  end
end