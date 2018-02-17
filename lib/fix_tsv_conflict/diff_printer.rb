module FixTsvConflict
  class DiffPrinter
    def initialize(stderr: $stderr)
      @stderr = stderr
      @left, @right = {}, {}
    end

    def print(cols, left, lbranch, right, rbranch)
      @lbranch, @rbranch = lbranch, rbranch

      left  = left.chomp.split(TAB)
      right = right.chomp.split(TAB)

      cols.each do |col, i|
        l, r = left[i], right[i]
        if l == r
          flush_conflicts if in_conflict?
          print_col_and_value(col, l)
        else
          @left[col]  = l
          @right[col] = r
        end
      end

      flush_conflicts
    end

    def flush_conflicts
      @stderr.puts "#{LEFT} #{@lbranch}"
      @left.each do |c, v|
        print_col_and_value(c, v)
      end
      @stderr.puts SEP
      @right.each do |c, v|
        print_col_and_value(c, v)
      end
      @stderr.puts "#{RIGHT} #{@rbranch}"

      @left.clear
      @right.clear
    end

    def print_col_and_value(col, value)
      @stderr.puts [col, value].join(TAB)
    end

    def in_conflict?
      @left.length > 0 || @right.length > 0
    end
  end
end
