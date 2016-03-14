require "test_helper"

class TestPasswordStrength < Minitest::Test
  def setup
    @strength = PasswordStrength::Base.new("johndoe", "mypass")
  end

  def test_shortcut
    @strength = PasswordStrength.test("johndoe", "mypass")

    assert_kind_of PasswordStrength::Base, @strength
    assert_equal "johndoe", @strength.username
    assert_equal "mypass", @strength.password
  end

  def test_deal_with_empty_password
    @strength = PasswordStrength.test("johndoe", "")
    assert @strength.weak?

  end

  def test_good_strength
    @strength.instance_variable_set("@status", :good)
    assert @strength.good?
    assert @strength.valid?(:good)
    refute @strength.weak?
    refute @strength.strong?
  end

  def test_weak_strength
    @strength.instance_variable_set("@status", :weak)
    assert @strength.weak?
    assert @strength.valid?(:weak)
    refute @strength.good?
    refute @strength.strong?
  end

  def test_strong_strength
    @strength.instance_variable_set("@status", :strong)
    assert @strength.strong?
    assert @strength.valid?(:strong)
    assert @strength.valid?(:good)
    refute @strength.good?
    refute @strength.weak?
  end

  def test_short_password
    @strength.password = "xyz"
    @strength.test

    assert_equal 0, @strength.score
    assert_equal :weak, @strength.status
  end

  def test_password_equals_to_username
    @strength.password = "johndoe"
    @strength.test

    assert_equal 0, @strength.score
    assert_equal :weak, @strength.status
  end

  def test_strong_password
    @strength.password = "^P4ssw0rd$"
    @strength.test

    assert_equal 100, @strength.score
    assert_equal :strong, @strength.status
  end

  def test_weak_password
    @strength.password = "ytrewq"
    @strength.test
    assert_equal :weak, @strength.status

    @strength.password = "asdfghjklm"
    @strength.test
    assert_equal :weak, @strength.status
  end

  def test_good_password
    @strength.password = "12345asdfg"
    @strength.test
    assert_equal :good, @strength.status

    @strength.password = "12345ASDFG"
    @strength.test
    assert_equal :good, @strength.status

    @strength.password = "12345Aa"
    @strength.test
    assert_equal :good, @strength.status
  end

  def test_penalize_password_with_chars_only
    @strength.password = "abcdef"
    assert_equal -15, @strength.score_for(:only_chars)
  end

  def test_penalize_password_with_numbers_only
    @strength.password = "12345"
    assert_equal -15, @strength.score_for(:only_numbers)
  end

  def test_penalize_password_equals_to_username
    @strength.username = "johndoe"
    @strength.password = "johndoe"
    assert_equal -100, @strength.score_for(:username)
  end

  def test_penalize_password_with_username
    @strength.username = "johndoe"
    @strength.password = "$1234johndoe^"
    assert_equal -15, @strength.score_for(:username)
  end

  def test_penalize_number_sequence
    @strength.password = "234"
    assert_equal -15, @strength.score_for(:sequences)

    @strength.password = "123123"
    assert_equal -30, @strength.score_for(:sequences)
  end

  def test_penalize_letter_sequence
    @strength.password = "abc"
    assert_equal -15, @strength.score_for(:sequences)

    @strength.password = "abcabc"
    assert_equal -30, @strength.score_for(:sequences)
  end

  def test_penalize_number_and_letter_sequence
    @strength.password = "123abc"
    assert_equal -30, @strength.score_for(:sequences)

    @strength.password = "123abc123abc"
    assert_equal -60, @strength.score_for(:sequences)
  end

  def test_penalize_same_letter_sequence
    @strength.password = "aaa"
    assert_equal -30, @strength.score_for(:sequences)
  end

  def test_penalize_same_number_sequence
    @strength.password = "111"
    assert_equal -30, @strength.score_for(:sequences)
  end

  def test_penalize_reversed_sequence
    @strength.password = "cba321"
    assert_equal -30, @strength.score_for(:sequences)

    @strength.password = "cba321cba321"
    assert_equal -60, @strength.score_for(:sequences)
  end

  def test_penalize_short_password
    @strength.password = "abc"
    assert_equal -100, @strength.score_for(:password_size)
  end

  def test_penalize_repetitions
    # 2-chars: ab, bc, cd, da           (4 * 4 = 16)
    # 3-chars: abc, bcd, cda, dab       (4 * 3 = 12)
    # 4-chars: abcd, bcda, cdab, dabc   (4 * 2 =  8)
    @strength.password = "abcdabcdabcd"
    assert_equal -36, @strength.score_for(:repetitions)
  end

  def test_password_length
    @strength.password = "123456"
    assert_equal 24, @strength.score_for(:password_size)
  end

  def test_password_with_numbers
    @strength.password = "123"
    assert_equal 5, @strength.score_for(:numbers)
  end

  def test_password_with_symbols
    @strength.password = "$!"
    assert_equal 5, @strength.score_for(:symbols)
  end

  def test_password_with_upper_and_lower_chars
    @strength.password = "aA"
    assert_equal 10, @strength.score_for(:uppercase_lowercase)
  end

  def test_password_with_numbers_and_chars
    @strength.password = "a1"
    assert_equal 15, @strength.score_for(:numbers_chars)
  end

  def test_password_with_numbers_and_symbols
    @strength.password = "1$"
    assert_equal 15, @strength.score_for(:numbers_symbols)
  end

  def test_password_with_symbols_and_chars
    @strength.password = "a$"
    assert_equal 15, @strength.score_for(:symbols_chars)
  end

  def test_two_chars_repetition
    # expected: 11, 22, 12
    assert_equal 3, @strength.repetitions("11221122", 2)
  end

  def test_three_chars_repetition
    # expected: 123, 231, 312
    assert_equal 3, @strength.repetitions("123123123", 3)
  end

  def test_four_chars_repetition
    # expected: abcd, bcda, cdab, dabc
    assert_equal 4, @strength.repetitions("abcdabcdabcd", 4)
  end

  def test_special_chars_repetition
    # expected: §§, ££, §£
    assert_equal 3, @strength.repetitions("§§££§§££", 2)

    # expected: §£€, £€§, €§£
    assert_equal 3, @strength.repetitions("§£€§£€§£€", 3)

    # expected: §£€à, £€à§, €à§£, à§£€
    assert_equal 4, @strength.repetitions("§£€à§£€à§£€à", 4)
  end

  def test_reject_long_passwords_using_same_character
    @strength = PasswordStrength.test("johndoe", "a" * 50)
    assert_equal :invalid, @strength.status
    assert @strength.invalid?
    refute @strength.valid?
  end

  def test_exclude_option_as_regular_expression
    @strength = PasswordStrength.test("johndoe", "^Str0ng P4ssw0rd$", :exclude => /\s/)
    assert_equal :invalid, @strength.status
    assert @strength.invalid?
    refute @strength.valid?
  end

  def test_exclude_option_as_array
    @strength = PasswordStrength.test("johndoe", "asdfasdfasdf", :exclude => ["asdf", "123"])
    assert_equal :invalid, @strength.status
    assert @strength.invalid?
    refute @strength.valid?
  end

  def test_loads_common_words
    assert PasswordStrength::Base.common_words.size > 500
  end

  def test_reject_common_words
    $BREAKPOINT = true
    password = PasswordStrength::Base.common_words.first
    @strength = PasswordStrength.test("johndoe", password)
    assert @strength.invalid?, "#{password} must be invalid"
    refute @strength.valid?
    assert_equal :invalid, @strength.status
    $BREAKPOINT = false
  end
end
