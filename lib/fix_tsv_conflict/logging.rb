require "fix_tsv_conflict/refinements/colored_string"

module FixTSVConflict
  module Logging
    using Refinements::ColoredString

    def log(message, **options)
      if options[:no_newline]
        stderr.print message.chomp
      else
        stderr.puts message
      end
    end

    def info(message, **options)
      log message, options
    end

    def error(message, **options)
      log message.to_s.red
    end

    def warn(message, **options)
      log message.to_s.yellow
    end

    def notice(message, **options)
      log message.to_s.green
    end

    def dump(lines, **options)
      Array(lines).each do |line|
        log line.gsub(/^/, "  "), options
      end
    end

    def blank
      stderr.puts
    end
  end
end
