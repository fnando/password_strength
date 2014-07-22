ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup"
require "test/unit"
require "ostruct"
require "active_record"

I18n.enforce_available_locales = false

Rails = OpenStruct.new(:version => ActiveRecord::VERSION::STRING)
require "password_strength"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
load "schema.rb"
