require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'gherkin/tools/pretty_listener'


module Gherkin
  module Tools
    describe Colors do
      include Colors

      it "should colour stuff red" do
        failed("hello").should == "\e[31mhello\e[0m"
      end

      it "should be possible to specify no colouring" do
        failed("hello", true).should == "hello"
      end
    end
  end
end
