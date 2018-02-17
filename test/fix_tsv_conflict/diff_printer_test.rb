require "test_helper"

class DiffPrinterTest < Minitest::Test
  def test_print
    stderr = StringIO.new
    printer = FixTsvConflict::DiffPrinter.new(stderr: stderr)
    cols = { "id" => 0, "name" => 1 }
    lbranch = "add_joey_1"
    rbranch = "add_joseph_2"
    left  = "3\tJoey\n"
    right = "3\tJoseph\n"
    printer.print(cols, left, lbranch, right, rbranch)
    expected = <<-TEXT
id\t3
<<<<<<< add_joey_1
name\tJoey
=======
name\tJoseph
>>>>>>> add_joseph_2
    TEXT
    assert_equal expected, stderr.string
  end

  def test_print_with_adjacent_conflicts
    stderr = StringIO.new
    printer = FixTsvConflict::DiffPrinter.new(stderr: stderr)
    cols = { "id" => 0, "name" => 1, "job" => 2 }
    lbranch = "add_joey_1"
    rbranch = "add_joseph_2"
    left  = "3\tJoey\tcomedian\n"
    right = "3\tJoseph\tpilot\n"
    printer.print(cols, left, lbranch, right, rbranch)
    expected = <<-TEXT
id\t3
<<<<<<< add_joey_1
name\tJoey
job\tcomedian
=======
name\tJoseph
job\tpilot
>>>>>>> add_joseph_2
    TEXT
    assert_equal expected, stderr.string
  end
end
