module Gherkin
  module Parser
    class Table
      %%{      
        machine table;

        action start_row {
          current_row = []
          @begin_row = p
        }

        action begin_content {
          @content_start = p
        }

        action store_row {
          @rows << current_row
        }

        action store_cell_content {
          con = data[@content_start...p].pack("c*").strip
          current_row << (con.empty? ? nil : con)
        }

        action no_content {
          current_row << nil
        }
     
        action inc_line_number {
          @current_line += 1
        }
 
        action store_table {
          if @rows.size != 0
            @listener.table(@rows, @line)
          end
        }
        
        action end_table {
          if cs < table_first_final
            raise ParsingError.new(@current_line)
          end
        }

        include table_common "table_common.rl";
      }%%

      def initialize(listener,line)
        @line = line
        @current_line = line
        @listener = listener
        %% write data;
      end

      def scan(data)
        @rows = []
        data = (data + "\n").unpack("c*")
        pe = eof = data.length
    
        %% write init;
        %% write exec;
      end
    end
  end
end
