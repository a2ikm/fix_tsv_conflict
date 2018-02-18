require "fix_tsv_conflict/diff_printer"

module StringExt
  BLANK_RE = /\A[[:space:]]*\z/
  refine String do
    def blank?
      BLANK_RE === self
    end
  end
end

module FixTsvConflict
  class Repairman
    using StringExt

    def initialize(stdin: $stdin, stderr: $stderr)
      @stdin  = stdin
      @stderr = stderr
    end

    def repair(source)
      result = []
      branch, left, right = nil, [], []

      source.each_line.with_index do |line, i|
        parse_header(line) if i.zero?
        if branch
          if line.start_with?(RIGHT)
            @rbranch = line.chomp.split(" ").last
            result += resolve(left, right)
            branch = nil
          elsif line.start_with?(SEP)
            branch = right
          else
            branch << line
          end
        else
          if line.start_with?(LEFT)
            @lbranch = line.chomp.split(" ").last
            branch = left
          else
            result << line
          end
        end
      end
      result.join
    end

    def resolve(left, right)
      left  = index_by_id(left.reject(&:blank?))
      right = index_by_id(right.reject(&:blank?))
      (left.keys + right.keys).uniq.sort.map do |id|
        l = left[id]
        r = right[id]
        if l && r
          select(l, r)
        else
          l || r
        end
      end
    end

    def select(l, r)
      selected = if l.rstrip == r.rstrip
        correct_trailing_tabs(l)
      else
        prompt(l, r)
      end
    end

    def prompt(l, r)
      print_diff(l, r)
      prompt_select(l, r)
    end

    def print_diff(l, r)
      printer = DiffPrinter.new(stderr: @stderr)
      printer.print(@cols, l, @lbranch, r, @rbranch)
    end

    def prompt_select(l, r)
      text = <<-TEXT
Which do you want keep?

1) #{@lbranch}
2) #{@rbranch}
3) both of them

Please enter 1, 2, or 3:
      TEXT

      @stderr.print text.chomp

      loop do
        case selected = @stdin.gets.strip
        when "1"
          break l
        when "2"
          break r
        when "3"
          break "#{LEFT} #{@lbranch}\n#{l}#{SEP}\n#{r}#{RIGHT} #{@rbranch}\n"
        else
          text = <<-TEXT
Invalid input: #{selected}
Please enter 1, 2, or 3:
          TEXT
          @stderr.print text.chomp
        end
      end
    end

    def index_by_id(lines)
      result = {}
      lines.each do |line|
        id = line.split(TAB, 2).first
        result[id] = line
      end
      result
    end

    def parse_header(line)
      @cols = {}
      line.chomp.split(TAB).each.with_index do |col, i|
        @cols[col] = i
      end
      @tabs = @cols.length - 1
    end

    def correct_trailing_tabs(line)
      if line.count(TAB) == @tabs
        line
      else
        line = line.rstrip
        line + TAB * (@tabs - line.count(TAB))  + LF
      end
    end
  end
end
