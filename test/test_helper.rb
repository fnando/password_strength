ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup"
require "test/unit"
require "ostruct"
require "active_model"
require "active_support/all"

I18n.enforce_available_locales = false
require "password_strength"
