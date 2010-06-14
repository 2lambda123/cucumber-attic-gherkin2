require 'json'
require 'json/pure' # Needed to make JSON.generate work.
require 'gherkin/rubify'

module Gherkin
  module Formatter
    class JSONFormatter
      include Rubify
      
      def initialize(io)
        @io = io
      end

      def feature(comments, tags, keyword, name, description, uri)
        @json_hash = {
          'comments' => comments.to_a, 
          'tags' => tags.to_a, 
          'keyword' => keyword, 
          'name' => name, 
          'description' => description, 
          'uri' => uri
        }
      end

      def scenario(comments, tags, keyword, name, description, line)
        add_step_container(comments, tags, keyword, name, description, line)
      end

      def scenario_outline(comments, tags, keyword, name, description, line)
        add_step_container(comments, tags, keyword, name, description, line)
      end

      def examples(comments, tags, keyword, name, description, line, table)
        @table_container = add_element(comments, tags, keyword, name, description, line)
        @table_container['examples_table'] = to_hash_array(table)
      end

      def step(comments, keyword, name, line, multiline_arg, status, exception, arguments, stepdef_location)
        multiline_arg = rubify(multiline_arg)
        multiline_arg = to_hash_array(multiline_arg) if Array === multiline_arg
        @table_container = {'comments' => comments.to_a, 'keyword' => keyword, 'name' => name, 'line' => line, 'multiline_arg' => multiline_arg}
        last_element['steps'] ||= []
        last_element['steps'] << @table_container
      end

      def eof
        @io.write(@json_hash.to_json)
      end

    private

      def add_element(comments, tags, keyword, name, description, line)
        element = {
          'comments' => comments.to_a, 
          'tags' => tags.to_a, 
          'keyword' => keyword, 
          'name' => name, 
          'description' => description,
          'line' => line
        }
        @json_hash['elements'] ||= []
        @json_hash['elements'] << element
        element
      end

      def add_step_container(comments, tags, keyword, name, description, line)
        add_element(comments, tags, keyword, name, description, line)
        last_element['steps'] = []
      end

      def last_element
        @json_hash['elements'][-1]
      end

      def to_hash_array(rows)
        rows.map do |row|
          {"cells" => row.cells.to_a, "comments" => row.comments.to_a, "line" => row.line}
        end
      end
    end
  end
end