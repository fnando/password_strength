require "active_model"
require "password_strength/base"
require "password_strength/engine" if defined?(Rails::Engine)
require "password_strength/active_model"
require "password_strength/validators/windows2008"

# I18n.load_path += Dir[File.dirname(__FILE__) + "/../locales/**/*.yml"]
I18n.load_path += Dir[File.expand_path("../../locales/*.yml", __FILE__)]

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

  class << self
    # You can disable PasswordStrength without having to change a single line of code. This is
    # specially great on development environment.
    attr_accessor :enabled
  end

  # Enable verification by default.
  self.enabled = true
end
