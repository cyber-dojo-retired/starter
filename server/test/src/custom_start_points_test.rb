require_relative 'test_base'

class CustomStartPointsTest < TestBase

  def self.hex_prefix
    '72110'
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '9C1',
  %w( display-names are unique and sorted ) do
    sp = custom_start_points
    expected = [
      'Yahtzee refactoring, C# NUnit',
      'Yahtzee refactoring, C++ (g++) assert',
      'Yahtzee refactoring, Java JUnit',
      'Yahtzee refactoring, Python unitttest'
    ]
    assert_equal expected, sp
  end

end
