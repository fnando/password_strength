require "active_support"
require "password_strength/base"
require "password_strength/active_record"

module PasswordStrength
  # Test the password strength by applying several rules.
  # The username is required to match its substring in passwords.
  #
  #   strength = PasswordStrength.test("johndoe", "mypass")
  #   strength.weak?
  #   #=> true
  #
  # You can provide an options hash.
  #
  #   strength = PasswordStrength.test("johndoe", "^Str0ng P4ssw0rd$", :exclude => /\s/)
  #   strength.status
  #   #=> :invalid
  #
  #   strength.invalid?
  #   #=> true
  #
  # You can also provide an array.
  #
  #   strength = PasswordStrength.test("johndoe", "^Str0ng P4ssw0rd$", :exclude => [" ", "asdf", "123"])
  #
  def self.test(username, password, options = {})
    strength = Base.new(username, password, options)
    strength.test
    strength
  end
end
