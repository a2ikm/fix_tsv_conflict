require "test_helper"

class RepairmanTest < Minitest::Test
  def test_repair_with_no_conflicts
    repairman = FixTsvConflict::Repairman.new
    source = <<-TEXT
id\tname
1\tJess
2\tDanny
3\tJoey
    TEXT
    assert_equal source, repairman.repair(source)
  end

  def test_repair_with_conflicted_new_records_for_different_ids
    repairman = FixTsvConflict::Repairman.new
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
end
