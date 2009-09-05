module Gherkin
  module Parser
    class Misc
      %%{
        machine misc;
        
        action start {
          start_col = p - @last_newline
          start = p + 4
        }

        # Unused
        action end {
          pystring_content = data[start...(p - 4)].pack("U*")
          @lines << pystring_content
        }
        
        action start_line {
          line_col = p - @last_newline
          line_start = p
        }
        
        action end_line {
          line = data[line_start...p].pack("U*")
          offset = line_col - start_col
          @lines << (offset >= 0 ? line.gsub(/^/, ' ' * offset) : line)
        }
        
        newline = ('\r'? '\n') @{ @last_newline = p + 1} ;
        
        PyStringStart = '"""' space* newline ;
        PyStringEnd = '"""' ;
        PyStringLine = space* ( any* >start_line %end_line ) newline;
        PyString = PyStringStart PyStringLine PyStringEnd ;

        main := space* PyString >start ;
      }%%
      
      def initialize(listener)
        @listener = listener
        @last_newline = 0
        @lines = []
        %% write data;
      end
      
      def scan(data)
        data = data.unpack("U*") if data.is_a?(String)
        eof = data.length
        
        %% write init;
        %% write exec;
        
        @listener.pystring(@lines.join)
      end
    end
  end
end
