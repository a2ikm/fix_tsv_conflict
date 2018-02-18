require "test_helper"

class CLITest < Minitest::Test
  def test_handle_argv_with_empty
    $stderr = StringIO.new
    cli = FixTsvConflict::CLI.new
    argv = []
    assert_raises SystemExit do
      cli.handle_argv(argv)
    end
  end

  def test_handle_argv_with_path
    cli = FixTsvConflict::CLI.new
    argv = %w(/path/to/tsv)
    expected = ["/path/to/tsv", {}]
    assert_equal expected, cli.handle_argv(argv)
  end

  def test_handle_argv_with_path_and_options
    cli = FixTsvConflict::CLI.new
    argv = %w(-O /path/to/tsv)
    expected = ["/path/to/tsv", { override: true }]
    assert_equal expected, cli.handle_argv(argv)
  end
end
