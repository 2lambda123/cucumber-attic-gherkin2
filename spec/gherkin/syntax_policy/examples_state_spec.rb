require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Gherkin
  module SyntaxPolicy
    describe "Example state" do
      before do
        @state = ExamplesState.new
        @state.examples
      end

      it "should allow tables, examples, scenarios, scenario outlines, comments and tags" do
        [:table, :examples, :tag, :comment, :scenario, :scenario_outline].each do |event|
          @state.should allow(event)
        end
      end

      it "should not allow steps, py_strings, features or backgrounds" do
        [:step, :py_string, :feature, :background].each do |event|
          @state.should_not allow(event)
        end
      end
    end
  end
end