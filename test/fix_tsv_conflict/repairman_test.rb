require "test_helper"

class RepairmanTest < Minitest::Test
  def test_repair_with_no_conflicts
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal source, repairman.repair(source)
  end

  def test_repair_with_multiple_adding_conflicts
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
<<<<<<< HEAD
1\tJess
=======
>>>>>>> add_jess_and_joey
2\tDanny
<<<<<<< HEAD
3\tJoey
======= add_jess_and_joey
>>>>>>> add_jess_and_joey
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_new_blank_lines_right
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
<<<<<<< add_danny
2\tDanny
=======

>>>>>>> add_blank
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_new_blank_lines_left
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
<<<<<<< add_danny

=======
2\tDanny
>>>>>>> add_blank
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_conflicted_new_records_for_different_ids
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
<<<<<<< add_danny
2\tDanny
=======
3\tJoey
>>>>>>> add_joey
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_conflicted_new_records_for_different_ids_reversed
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
<<<<<<< add_danny
3\tJoey
=======
2\tDanny
>>>>>>> add_joey
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_trailing_tabs_right
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey_1
3\tJoey
=======
3\tJoey\t
>>>>>>> add_joey_2
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_trailing_tabs_left
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey_1
3\tJoey\t
=======
3\tJoey
>>>>>>> add_joey_2
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_lack_of_tabs_right
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname\tjob
1\tJess\tmusician
2\tDanny\tnewscaster
<<<<<<< add_joey_1
3\tJoey
=======
3\tJoey\t
>>>>>>> add_joey_2
    TEXT
    expected = <<-TEXT
id\tname\tjob
1\tJess\tmusician
2\tDanny\tnewscaster
3\tJoey\t
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_lack_of_tabs_left
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stderr: stderr)
    source = <<-TEXT
id\tname\tjob
1\tJess\tmusician
2\tDanny\tnewscaster
<<<<<<< add_joey_1
3\tJoey\t
=======
3\tJoey
>>>>>>> add_joey_2
    TEXT
    expected = <<-TEXT
id\tname\tjob
1\tJess\tmusician
2\tDanny\tnewscaster
3\tJoey\t
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_selecting_left
    stdin = StringIO.new("1\n")
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stdin: stdin, stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey
3\tJoey
=======
3\tJoseph
>>>>>>> add_joseph
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_selecting_right
    stdin = StringIO.new("2\n")
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stdin: stdin, stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey
3\tJoey
=======
3\tJoseph
>>>>>>> add_joseph
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoseph
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_selecting_invalid_loop
    stdin = StringIO.new("invalid\n2\n")
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stdin: stdin, stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey
3\tJoey
=======
3\tJoseph
>>>>>>> add_joseph
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoseph
    TEXT
    assert_equal expected, repairman.repair(source)
  end

  def test_repair_with_selecting_keep_as_is
    stdin = StringIO.new("k\n")
    stderr = StringIO.new
    repairman = FixTSVConflict::Repairman.new(stdin: stdin, stderr: stderr)
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey
3\tJoey
=======
3\tJoseph
>>>>>>> add_joseph
    TEXT
    expected = <<-TEXT
id\tname
1\tJess
2\tDanny
<<<<<<< add_joey
3\tJoey
=======
3\tJoseph
>>>>>>> add_joseph
    TEXT
    assert_equal expected, repairman.repair(source)
  end
end
