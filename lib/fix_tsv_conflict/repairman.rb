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

    TAB = "\t"

    def repair(source)
      result = []

      left  = []
      right = []
      branch = nil
      source.each_line.with_index do |line, i|
        parse_header(line) if i.zero?
        if branch
          if line.start_with?(">>>>>>>")
            result += resolve(left, right)
            branch = nil
          elsif line.start_with?("=======")
            branch = right
          else
            branch << line
          end
        else
          if line.start_with?("<<<<<<<")
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
          [l, r].detect do |line|
            line.split(TAB).length == @cols.length
          end
        else
          l || r
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
    end
  end
end
