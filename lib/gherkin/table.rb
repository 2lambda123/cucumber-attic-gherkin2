# line 1 "lib/gherkin/table.rl"
module Gherkin
  class Table
    # line 31 "lib/gherkin/table.rl"


    def initialize
      
# line 10 "lib/gherkin/table.rb"
class << self
	attr_accessor :_table_actions
	private :_table_actions, :_table_actions=
end
self._table_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3
]

class << self
	attr_accessor :_table_key_offsets
	private :_table_key_offsets, :_table_key_offsets=
end
self._table_key_offsets = [
	0, 0, 4, 13, 23, 27, 38
]

class << self
	attr_accessor :_table_trans_keys
	private :_table_trans_keys, :_table_trans_keys=
end
self._table_trans_keys = [
	32, 124, 9, 13, 32, 9, 13, 48, 
	57, 65, 90, 97, 122, 32, 124, 9, 
	13, 48, 57, 65, 90, 97, 122, 32, 
	124, 9, 13, 10, 13, 32, 9, 12, 
	48, 57, 65, 90, 97, 122, 32, 124, 
	9, 13, 0
]

class << self
	attr_accessor :_table_single_lengths
	private :_table_single_lengths, :_table_single_lengths=
end
self._table_single_lengths = [
	0, 2, 1, 2, 2, 3, 2
]

class << self
	attr_accessor :_table_range_lengths
	private :_table_range_lengths, :_table_range_lengths=
end
self._table_range_lengths = [
	0, 1, 4, 4, 1, 4, 1
]

class << self
	attr_accessor :_table_index_offsets
	private :_table_index_offsets, :_table_index_offsets=
end
self._table_index_offsets = [
	0, 0, 4, 10, 17, 21, 29
]

class << self
	attr_accessor :_table_indicies
	private :_table_indicies, :_table_indicies=
end
self._table_indicies = [
	0, 2, 0, 1, 3, 3, 4, 4, 
	4, 1, 5, 7, 5, 6, 6, 6, 
	1, 8, 9, 8, 1, 10, 11, 9, 
	9, 4, 4, 4, 1, 0, 2, 0, 
	1, 0
]

class << self
	attr_accessor :_table_trans_targs
	private :_table_trans_targs, :_table_trans_targs=
end
self._table_trans_targs = [
	1, 0, 2, 2, 3, 4, 3, 5, 
	4, 5, 6, 5
]

class << self
	attr_accessor :_table_trans_actions
	private :_table_trans_actions, :_table_trans_actions=
end
self._table_trans_actions = [
	0, 0, 1, 0, 7, 5, 0, 5, 
	0, 0, 3, 3
]

class << self
	attr_accessor :table_start
end
self.table_start = 1;
class << self
	attr_accessor :table_first_final
end
self.table_first_final = 6;
class << self
	attr_accessor :table_error
end
self.table_error = 0;

class << self
	attr_accessor :table_en_main
end
self.table_en_main = 1;

# line 35 "lib/gherkin/table.rl"
    end

    def scan(data, listener)
      @rows = current_row = []
      data = data.unpack("c*") if data.is_a?(String)
      
# line 120 "lib/gherkin/table.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = table_start
end
# line 41 "lib/gherkin/table.rl"
      
# line 128 "lib/gherkin/table.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _table_key_offsets[cs]
	_trans = _table_index_offsets[cs]
	_klen = _table_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _table_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _table_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _table_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _table_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _table_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _table_indicies[_trans]
	cs = _table_trans_targs[_trans]
	if _table_trans_actions[_trans] != 0
		_acts = _table_trans_actions[_trans]
		_nacts = _table_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _table_actions[_acts - 1]
when 0 then
# line 6 "lib/gherkin/table.rl"
		begin

        current_row = []
      		end
# line 6 "lib/gherkin/table.rl"
when 1 then
# line 10 "lib/gherkin/table.rl"
		begin

        @rows << current_row
      		end
# line 10 "lib/gherkin/table.rl"
when 2 then
# line 14 "lib/gherkin/table.rl"
		begin

        d = data[@_s..(p-1)].pack('c*')
        current_row << d
      		end
# line 14 "lib/gherkin/table.rl"
when 3 then
# line 19 "lib/gherkin/table.rl"
		begin

        @_s = p
      		end
# line 19 "lib/gherkin/table.rl"
# line 238 "lib/gherkin/table.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	end
	if _goto_level <= _out
		break
	end
	end
	end
# line 42 "lib/gherkin/table.rl"
      listener.table(@rows)
    end
  end
end
