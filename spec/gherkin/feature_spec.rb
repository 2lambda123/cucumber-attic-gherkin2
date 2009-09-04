#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Gherkin
  module Parser
    describe Feature do
  
      def scan_file(file)
        Feature.new(@listener).scan(File.new(File.dirname(__FILE__) + "/gherkin_parser/" + file).read)
      end

      before(:each) do
        @listener = mock('listener').as_null_object
      end

      describe "A single feature, single scenario, single step" do
        
        after(:each) do
          Feature.new(@listener).scan("Feature: Feature Text\n  Scenario: Reading a Scenario\n    Given there is a step\n")
        end

        it "should find the feature" do
          @listener.should_receive(:feature).with("Feature Text").once
        end
       
        it "should find the scenario" do
          @listener.should_receive(:scenario).with("Reading a Scenario").once
        end

        it "should find the step" do
          @listener.should_receive(:step).with("there is a step").once
        end
      end

      describe "A single feature, single scenario, three steps" do
        
        after(:each) do
          Feature.new(@listener).scan("Feature: Feature Text\n  Scenario: Reading a Scenario\n    Given there is a step\n    And another step\n   And a third step\n")
        end

        it "should find the feature" do
          @listener.should_receive(:feature).with("Feature Text").once
        end
       
        it "should find the scenario" do
          @listener.should_receive(:scenario).with("Reading a Scenario").once
        end

        it "should find the step" do
          @listener.should_receive(:step).with("there is a step").ordered
          @listener.should_receive(:step).with("another step").ordered
          @listener.should_receive(:step).with("a third step").ordered
        end
      end

      describe "A single feature with no scenario" do
        it "should find the feature" do
          @listener.should_receive(:feature).with("Feature Text").once
          Feature.new(@listener).scan("Feature: Feature Text\n")
        end
      end
      
      describe "A multi-line feature with no scenario" do
        it "should find the feature" do
          pending
          @listener.should_receive(:feature).with("Feature Text\n  And some more text").once
          Feature.new(@listener).scan("Feature: Feature Text\n  And some more text")
        end
      end

      describe "A feature with a scenario but no steps" do
        after(:each) do
          Feature.new(@listener).scan("Feature: Feature Text\nScenario: Reading a Scenario\n")
        end

        it "should find the feature" do
          @listener.should_receive(:feature).with("Feature Text").once
        end

        it "should find the scenario" do
          @listener.should_receive(:scenario).with("Reading a Scenario").once
        end
      end

      describe "A feature with two scenarios" do
        after(:each) do
          Feature.new(@listener).scan("Feature: Feature Text\nScenario: Reading a Scenario\n  Given a step\n\nScenario: A second scenario\n Given another step\n")
        end

        it "should find things in the right order" do
          @listener.should_receive(:feature).with("Feature Text").ordered
          @listener.should_receive(:scenario).with("Reading a Scenario").ordered
          @listener.should_receive(:step).with("a step").ordered
          @listener.should_receive(:scenario).with("A second scenario").ordered
          @listener.should_receive(:step).with("another step").ordered
        end
      end
    end
  end
end
