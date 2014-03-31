require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"
require "rdoc/task"

Rake::TestTask.new do |t|
  t.libs += %w[test lib]
  t.ruby_opts = %w[-rubygems]
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.title = "Password Strength"
  rdoc.options += %w[ --line-numbers --inline-source --charset utf-8 ]
  rdoc.rdoc_files.include("README.rdoc", "CHANGELOG.rdoc")
  rdoc.rdoc_files.include("lib/**/*.rb")
end
