module FixTSVConflict
  class Conflict
    attr_reader :left, :lbranch, :right, :rbranch

    def initialize(left, lbranch, right, rbranch)
      @left = left
      @lbranch = lbranch
      @right = right
      @rbranch = rbranch
    end

    ID_REGEXP = /\A[0-9]+\t/
    NL_REGEXP = /\A\n/

    def valid?
      left.all? { |line| ID_REGEXP =~ line || NL_REGEXP =~ line} &&
        right.all? { |line| ID_REGEXP =~ line || NL_REGEXP =~ line }
    end

    def to_a
      result = []
      result << "#{LEFT} #{lbranch}\n"
      result += left
      result << "#{SEP}\n"
      result += right
      result << "#{RIGHT} #{rbranch}\n"
      result
    end
  end
end
