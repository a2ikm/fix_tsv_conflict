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

    def repair(source)
      result = []

      left  = []
      right = []
      branch = nil
      source.each_line do |line|
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
      (left + right).reject(&:blank?).sort_by { |line| line.split("\t").first.to_i }
    end
  end
end
