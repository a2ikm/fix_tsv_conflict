module FixTSVConflict
  module Logging
    using Module.new {
      refine String do
        def red;    "\e[31m#{self}\e[0m"; end
        def green;  "\e[32m#{self}\e[0m"; end
        def yellow; "\e[33m#{self}\e[0m"; end
      end
    }

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
