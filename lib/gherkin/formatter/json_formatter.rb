require 'json'
require 'gherkin/formatter/model'
require 'gherkin/native'
require 'base64'

module Gherkin
  module Formatter
    # This class doesn't really generate JSON - instead it populates an Array that can easily
    # be turned into JSON.
    class JSONFormatter
      native_impl('gherkin')
      
      include Base64
      
      def initialize(io)
        raise "Must be writeable" unless io.respond_to?(:write)
        @io = io
        @feature_hashes = []
        @current_step_or_hook = nil
      end

      def uri(uri)
        @uri = uri
      end

      def feature(feature)
        @feature_hash = feature.to_hash
        @feature_hash['uri'] = @uri
        @feature_hashes << @feature_hash
      end

      def background(background)
        feature_elements << background.to_hash
      end

      def scenario(scenario)
        feature_elements << scenario.to_hash
      end

      def scenario_outline(scenario_outline)
        feature_elements << scenario_outline.to_hash
      end

      def examples(examples)
        all_examples << examples.to_hash
      end

      def step(step)
        @current_step_or_hook = step.to_hash
        steps << @current_step_or_hook
      end

      def match(match)
        @current_step_or_hook['match'] = match.to_hash
      end

      def result(result)
        @current_step_or_hook['result'] = result.to_hash
      end

      def hook(type, match, result)
        hooks = feature_element['hooks'] ||= []
        hooks << {'type' => type, 'match' => match.to_hash, 'result' => result.to_hash}
      end

      def embedding(mime_type, data)
        embeddings << {'mime_type' => mime_type, 'data' => encode64s(data)}
      end

      def write(text)
        output << text
      end

      def eof
      end

      def done
      end

      def close
        @io.write(@feature_hashes.to_json)
      end

    private

      def feature_elements
        @feature_hash['elements'] ||= []
      end

      def feature_element
        feature_elements[-1]
      end

      def all_examples
        feature_element['examples'] ||= []
      end

      def steps
        feature_element['steps'] ||= []
      end

      def embeddings
        @current_step_or_hook['embeddings'] ||= []
      end

      def output
        @current_step_or_hook['output'] ||= []
      end

      def encode64s(data)
        # Strip newlines
        Base64.encode64(data).gsub(/\n/, '')
      end
    end
  end
end

