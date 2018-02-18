require "fix_tsv_conflict/repairman"
require "optparse"

module FixTSVConflict
  class CLI
    def run(argv = ARGV)
      path, options = handle_argv(argv)

      source = File.read(path)
      output =  Repairman.new.repair(source)

      if options[:override]
        File.open(path, "w") { |f| f.write(output) }
      else
        puts output
      end
    end

    def handle_argv(argv)
      options = {}
      op = option_parser(options)
      op.parse!(argv)

      path = argv.shift
      abort(op.help) if path.nil?

      [path, options]
    end

    def option_parser(options)
      OptionParser.new do |op|
        op.banner = <<-BANNER
Usage: #{executable} [<options>] <tsv>
Options:
        BANNER

        op.on "-O", "--override", "Override source file" do
          options[:override] = true
        end
      end
    end

    def executable
      File.basename($0)
    end
  end
end
