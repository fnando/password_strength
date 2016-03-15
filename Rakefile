require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs += %w[test lib]
  t.ruby_opts = %w[-rubygems]
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

task :default => :test
