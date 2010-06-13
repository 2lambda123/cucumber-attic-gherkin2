# encoding: utf-8
require 'gherkin/formatter/colors'
require 'gherkin/formatter/monochrome_format'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/escaping'
require 'gherkin/native'

module Gherkin
  module Formatter
    class PrettyFormatter
      native_impl('gherkin')

      include Colors
      include Escaping

      def initialize(io, monochrome=false)
        @io = io
        @monochrome = monochrome
        @format = MonochromeFormat.new #@monochrome ? MonochromeFormat.new : AnsiColorFormat.new
      end

      def feature(comments, tags, keyword, name, location)
        @location = location
        @io.puts "#{format_comments(comments, '')}#{format_tags(tags, '')}#{keyword}: #{indent(name, '  ')}"
      end

      def background(keyword, name, line)
        @io.puts "\n#{grab_comments!('  ')}  #{keyword}: #{indent(name, '    ')}"
      end

      def scenario(comments, tags, keyword, name, line)
        @io.puts "\n#{format_comments(comments, '  ')}#{format_tags(tags, '  ')}  #{keyword}: #{indent(name, '    ')}#{indented_scenario_location!(keyword, name, line)}"
      end

      def scenario_outline(comments, tags, keyword, name, line)
        scenario(comments, tags, keyword, name, line)
      end

      def examples(comments, tags, keyword, name, line, examples_table)
        @io.puts "\n#{format_comments(comments, '    ')}#{format_tags(tags, '    ')}    #{keyword}: #{indent(name, '    ')}"
        table(examples_table)
      end

      def step(comments, keyword, name, line, multiline_arg, status=nil, exception=nil, arguments=nil, stepdef_location=nil)
        status_param = "#{status}_param" if status
        name = Gherkin::Formatter::Argument.format(name, @format, (arguments || [])) 

        step = "#{keyword}#{indent(name, '    ')}"
        step = self.__send__(status, step, @monochrome) if status

        @io.puts("#{format_comments(comments, '    ')}    #{step}#{indented_step_location!(stepdef_location)}")
        case multiline_arg
        when String
          py_string(multiline_arg)
        when Array
          table(multiline_arg)
        when NilClass
        else
          raise "Bad multiline_arg: #{multiline_arg.inspect}"
        end
      end

      def syntax_error(state, event, legal_events, line)
        raise "SYNTAX ERROR"
      end

      def eof
      end

      # This method can be invoked before a #scenario, to ensure location arguments are aligned
      def steps(steps)
        @step_lengths = steps.map {|keyword, name| (keyword+name).unpack("U*").length}
        @max_step_length = @step_lengths.max
        @step_index = -1
      end

      def table(rows)
        cell_lengths = rows.map do |col| 
          col.map do |cell| 
            escape_cell(cell).unpack("U*").length
          end
        end
        max_lengths = cell_lengths.transpose.map { |col_lengths| col_lengths.max }.flatten

        rows.each_with_index do |row, i|
          j = -1
          @io.puts '      | ' + row.zip(max_lengths).map { |cell, max_length|
            j += 1
            color(cell, nil, j) + ' ' * (max_length - cell_lengths[i][j])
          }.join(' | ') + ' |'
        end
      end

    private

      def py_string(string)
        @io.puts "      \"\"\"\n" + string.gsub(START, '      ').gsub(/"""/,'\"\"\"') + "\n      \"\"\""
      end

      def exception(exception)
        exception_text = "#{exception.message} (#{exception.class})\n#{(exception.backtrace || []).join("\n")}".gsub(/^/, '      ')
        @io.puts(failed(exception_text, @monochrome))
      end

      private

      def color(cell, statuses, col)
        if statuses
          self.__send__(statuses[col], escape_cell(cell), @monochrome) + (@monochrome ? '' : reset)
        else
          escape_cell(cell)
        end
      end

      if(RUBY_VERSION =~ /^1\.9/)
        START = /#{"^".encode('UTF-8')}/
        NL    = Regexp.new("\n".encode('UTF-8'))
      else
        START = /^/
        NL    = /\n/n
      end

      def indent(string, indentation)
        indent = ""
        string.split(NL).map do |l|
          s = "#{indent}#{l}"
          indent = indentation
          s
        end.join("\n")
      end

      def format_tags(tags, indent)
        tags.empty? ? '' : indent + tags.join(' ') + "\n"
      end

      def format_comments(comments, indent)
        comments.empty? ? '' : indent + comments.join("\n#{indent}") + "\n"
      end

      def indented_scenario_location!(keyword, name, line)
        return '' if @max_step_length.nil?
        l = (keyword+name).unpack("U*").length
        @max_step_length = [@max_step_length, l].max
        indent = @max_step_length - l
        ' ' * indent + ' ' + comments("# #{@location}:#{line}", @monochrome)
      end

      def indented_step_location!(location)
        return "" if location.nil?
        indent = @max_step_length - @step_lengths[@step_index+=1]
        ' ' * indent + ' ' + comments("# #{location}", @monochrome)
      end
    end
  end
end
