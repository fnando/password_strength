module PasswordStrength
  class Base
    MULTIPLE_NUMBERS_RE = /\d.*?\d.*?\d/
    MULTIPLE_SYMBOLS_RE = /[!@#\$%^&*?_~-].*?[!@#\$%^&*?_~-]/
    SYMBOL_RE = /[!@#\$%^&*?_~-]/
    UPPERCASE_LOWERCASE_RE = /([a-z].*[A-Z])|([A-Z].*[a-z])/

    # Hold the username that will be matched against password
    attr_accessor :username

    # The password that will be tested
    attr_accessor :password

    # The score for the latest test. Will be nil if the password has not been tested.
    attr_reader   :score

    # The current test status. Can be +:weak+, +:good+ or +:strong+
    attr_reader   :status

    def initialize(username, password)
      @username = username.to_s
      @password = password.to_s
      @score = 0
    end

    # Check if the password has the specified score.
    # Level can be +:weak+, +:good+ or +:strong+.
    def valid?(level)
      case level
      when :strong then
        strong?
      when :good then
        good? || strong?
      else
        true
      end
    end

    # Check if the password has been detected as strong.
    def strong?
      status == :strong
    end

    # Check if the password has been detected as weak.
    def weak?
      status == :weak
    end

    # Check if the password has been detected as good.
    def good?
      status == :good
    end

    # Return the score for the specified rule.
    # Available rules:
    #
    # * :password_size
    # * :numbers
    # * :symbols
    # * :uppercase_lowercase
    # * :numbers_chars
    # * :numbers_symbols
    # * :symbols_chars
    # * :only_chars
    # * :only_numbers
    # * :username
    # * :sequences
    def score_for(name)
      score = 0

      case name
      when :password_size then
        if password.size < 4
          score = -100
        else
          score = password.size * 4
        end
      when :numbers then
        score = 5 if password =~ MULTIPLE_NUMBERS_RE
      when :symbols then
        score = 5 if password =~ MULTIPLE_SYMBOLS_RE
      when :uppercase_lowercase then
        score = 10 if password =~ UPPERCASE_LOWERCASE_RE
      when :numbers_chars then
        score = 15 if password =~ /[a-z]/i && password =~ /[0-9]/
      when :numbers_symbols then
        score = 15 if password =~ /[0-9]/ && password =~ SYMBOL_RE
      when :symbols_chars then
        score = 15 if password =~ /[a-z]/i && password =~ SYMBOL_RE
      when :only_chars then
        score = -15 if password =~ /^[a-z]+$/i
      when :only_numbers then
        score = -15 if password =~ /^\d+$/
      when :username then
        if password == username
          score = -100
        else
          score = -15 if password =~ /#{Regexp.escape(username)}/
        end
      when :sequences then
        score = -15 * sequences(password)
        score += -15 * sequences(password.to_s.reverse)
      when :repetitions then
        score += -(repetitions(password, 2) * 4)
        score += -(repetitions(password, 3) * 3)
        score += -(repetitions(password, 4) * 2)
      end

      score
    end

    def test
      @score = 0
      @score += score_for(:password_size)
      @score += score_for(:numbers)
      @score += score_for(:symbols)
      @score += score_for(:uppercase_lowercase)
      @score += score_for(:numbers_chars)
      @score += score_for(:numbers_symbols)
      @score += score_for(:symbols_chars)
      @score += score_for(:only_chars)
      @score += score_for(:only_numbers)
      @score += score_for(:username)
      @score += score_for(:sequences)
      @score += score_for(:repetitions)

      @score = 0 if score < 0
      @score = 100 if score > 100

      @status = :weak   if score < 35
      @status = :good   if score >= 35 && score < 70
      @status = :strong if score >= 70

      score
    end

    def repetitions(text, size) # :nodoc:
      text = text.mb_chars
      count = 0
      matches = []

      0.upto(text.size - 1) do |i|
        substring = text[i, size]

        next if matches.include?(substring) || substring.size < size

        matches << substring
        occurrences = text.scan(/#{Regexp.escape(substring)}/).length
        count += 1 if occurrences > 1
      end

      count
    end

    def sequences(text) # :nodoc:
      matches = 0
      sequence_size = 0
      bytes = []

      text.to_s.each_byte do |byte|
        previous_byte = bytes.last
        bytes << byte

        if previous_byte && ((byte == previous_byte + 1) || (previous_byte == byte))
          sequence_size += 1
        else
          sequence_size = 0
        end

        matches += 1 if sequence_size == 2
      end

      matches
    end
  end
end
