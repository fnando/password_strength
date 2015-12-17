ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup"

require "minitest/autorun"

if defined?(Minitest::Test)
  begin
    require "minitest/utils"
  rescue LoadError
  end
else
  Minitest::Test = MiniTest::Unit::TestCase
end

require "ostruct"
require "active_model"
require "active_support/all"

I18n.enforce_available_locales = false
require "password_strength"
