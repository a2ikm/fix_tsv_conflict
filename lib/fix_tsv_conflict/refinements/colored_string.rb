module FixTSVConflict
  module Refinements
    module ColoredString
      refine String do
        def red;    "\e[31m#{self}\e[0m"; end
        def green;  "\e[32m#{self}\e[0m"; end
        def yellow; "\e[33m#{self}\e[0m"; end
        def cyan;   "\e[36m#{self}\e[0m"; end

        def bg_red;    "\e[41m#{self}\e[0m"; end
        def bg_green;  "\e[42m#{self}\e[0m"; end
        def bg_yellow; "\e[43m#{self}\e[0m"; end
        def bg_cyan;   "\e[46m#{self}\e[0m"; end
      end
    end
  end
end
