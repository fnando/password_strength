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
  def self.test(username, password)
    strength = Base.new(username, password)
    strength.test
    strength
  end
end
