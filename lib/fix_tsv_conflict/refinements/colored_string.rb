module FixTSVConflict
  module Refinements
    module ColoredString
      refine String do
        def red;    "\e[31m#{self}\e[0m"; end
        def green;  "\e[32m#{self}\e[0m"; end
        def yellow; "\e[33m#{self}\e[0m"; end
      end
    end
  end
end
