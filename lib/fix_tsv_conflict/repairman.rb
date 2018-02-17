require "fix_tsv_conflict/diff_printer"

module StringExt
  refine String do
    BLANK_RE = /\A[[:space:]]*\z/
    def blank?
      BLANK_RE === self
    end
  end
end

module FixTsvConflict
  class Repairman
    using StringExt

    def initialize(stdout: $stdout)
      @stdout = stdout
    end

    def repair(source)
      result = []
      branch, left, right = nil, [], []

      source.each_line.with_index do |line, i|
        parse_header(line) if i.zero?
        if branch
          if line.start_with?(RIGHT)
            @lbranch = line.chomp.split(" ").last
            result += resolve(left, right)
            branch = nil
          elsif line.start_with?(SEP)
            branch = right
          else
            branch << line
          end
        else
          if line.start_with?(LEFT)
            @rbranch = line.chomp.split(" ").last
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
      if l.rstrip == r.rstrip
        correct_trailing_tabs(l)
      else
        # Note: this is very naive.
        [l, r].detect do |line|
          line.count(TAB) == @tabs
        end
      end
    end

    def print_diff(l, r)
      printer = DiffPrinter.new(stdout: @stdout)
      printer.print(@cols, l, @lbranch, r, @rbranch)
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
