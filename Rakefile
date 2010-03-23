require "jeweler"
require "rcov/rcovtask"
require "rake/testtask"
require "hanna/rdoctask"
require "lib/password_strength/version"

Rcov::RcovTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
  t.rcov_opts = ["--sort coverage", "--exclude .renv,.bundle,helper,errors.rb"]

  t.output_dir = "coverage"
  t.libs << "test"
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
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

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "password_strength"
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://github.com/fnando/password_strength"
  gem.authors = ["Nando Vieira"]
  gem.version = PasswordStrength::Version::STRING
  gem.summary = "Check password strength against several rules. Includes ActiveRecord support."
  gem.description = <<-TXT
Validates the strength of a password according to several rules:

* size
* 3+ numbers
* 2+ special characters
* uppercased and downcased letters
* combination of numbers, letters and symbols
* password contains username
* sequences (123, abc, aaa)
TXT
  gem.files =  FileList["{README,CHANGELOG}.rdoc", "{lib,test}/**/*"]
  gem.add_dependency "activesupport"
end

Jeweler::GemcutterTasks.new