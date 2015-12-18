module PasswordStrength
  class Base
    MULTIPLE_NUMBERS_RE = /\d.*?\d.*?\d/
    MULTIPLE_SYMBOLS_RE = /[!@#\$%^&*?_~-].*?[!@#\$%^&*?_~-]/
    SYMBOL_RE = /[!@#\$%^&*?_~-]/
    UPPERCASE_LOWERCASE_RE = /([a-z].*[A-Z])|([A-Z].*[a-z])/
    INVALID = :invalid
    WEAK = :weak
    STRONG = :strong
    GOOD = :good

    # Hold the username that will be matched against password.
    attr_accessor :username

    # The password that will be tested.
    attr_accessor :password

    # The score for the latest test. Will be +nil+ if the password has not been tested.
    attr_reader   :score

    # The current test status. Can be +:weak+, +:good+, +:strong+ or +:invalid+.
    attr_reader   :status

    # The ActiveRecord instance.
    # It only makes sense if you're creating a custom ActiveRecord validator.
    attr_reader   :record

    # Set what characters cannot be present on password.
    # Can be a regular expression or array.
    #
    #   strength = PasswordStrength.test("john", "password with whitespaces", :exclude => [" ", "asdf"])
    #   strength = PasswordStrength.test("john", "password with whitespaces", :exclude => /\s/)
    #
    # Then you can check the test result:
    #
    #   strength.valid?(:weak)
    #   #=> false
    #
    #   strength.status
    #   #=> :invalid
    #
    attr_accessor :exclude

    # Return an array of strings that represents
    # common passwords. The default list is taken
    # from several online sources (just Google for 'most common passwords').
    #
    # Notable sources:
    #
    # * http://www.whatsmypass.com/the-top-500-worst-passwords-of-all-time
    # * http://elementdesignllc.com/2009/12/twitters-most-common-passwords/
    #
    # The current list has 3.6KB and its load into memory just once.
    def self.common_words
      @common_words ||= begin
        file = File.open(File.expand_path("../../../support/common.txt", __FILE__))
        words = file.each_line.to_a.map(&:chomp)
        file.close
        words
      end
    end

    def initialize(username, password, options = {})
      @username = username.to_s
      @password = password.to_s
      @score = 0
      @exclude = options[:exclude]
      @record = options[:record]
    end

    # Check if the password has the specified score.
    # Level can be +:weak+, +:good+ or +:strong+.
    def valid?(level = GOOD)
      case level
      when STRONG then
        strong?
      when GOOD then
        good? || strong?
      else
        !invalid?
      end
    end

    # Check if the password has been detected as strong.
    def strong?
      status == STRONG
    end

    # Mark password as strong.
    def strong!
      @status = STRONG
    end

    # Check if the password has been detected as weak.
    def weak?
      status == WEAK
    end

    # Mark password as weak.
    def weak!
      @status = WEAK
    end

    # Check if the password has been detected as good.
    def good?
      status == GOOD
    end

    # Mark password as good.
    def good!
      @status = GOOD
    end

    # Check if password has invalid characters based on PasswordStrength::Base#exclude.
    def invalid?
      status == INVALID
    end

    # Mark password as invalid.
    def invalid!
      @status = INVALID
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
        if password.size < 6
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

    # Run all tests on password and return the final score.
    def test
      @score = 0

      if contain_invalid_matches?
        invalid!
      elsif common_word?
        invalid!
      elsif contain_invalid_repetion?
        invalid!
      else
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

        weak!   if score < 35
        good!   if score >= 35 && score < 70
        strong! if score >= 70
      end

      score
    end

    def common_word? # :nodoc:
      self.class.common_words.include?(password.downcase)
    end

    def contain_invalid_matches? # :nodoc:
      return false unless exclude
      regex = exclude
      regex = /#{exclude.collect {|i| Regexp.escape(i)}.join("|")}/ if exclude.kind_of?(Array)
      password.to_s =~ regex
    end

    def contain_invalid_repetion?
      char = password.to_s.chars.first
      return unless char
      regex = /^#{Regexp.escape(char)}+$/i
      password.to_s =~ regex
    end

    def repetitions(text, size) # :nodoc:
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
