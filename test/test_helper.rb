$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require "rubygems"
require "test/unit"
require "ostruct"
require "active_record"

Rails = OpenStruct.new(:version => ActiveRecord::VERSION::STRING)
require "password_strength"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
load "schema.rb"
