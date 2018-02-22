module FixTSVConflict
  module Refinements
    module Blank
      BLANK_RE = /\A[[:space:]]*\z/

      refine String do
        def blank?
          BLANK_RE === self
        end
      end
    end
  end
end
