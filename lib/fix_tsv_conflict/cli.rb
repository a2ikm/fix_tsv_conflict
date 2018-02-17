require "fix_tsv_conflict/repairman"

module FixTsvConflict
  class CLI
    def run(argv = ARGV)
      path = argv.shift
      abort(help) if path.nil?

      source = File.read(path)
      puts Repairman.new.repair(source)
    end

    def help
      <<-HELP
Usage: #{$0} <tsv>
      HELP
    end
  end
end
