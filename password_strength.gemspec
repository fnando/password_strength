require "./lib/password_strength/version"

Gem::Specification.new do |s|
  s.name                  = "password_strength"
  s.version               = PasswordStrength::Version::STRING
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.9"
  s.authors               = ["Nando Vieira"]
  s.email                 = ["fnando.vieira@gmail.com"]
  s.homepage              = "http://github.com/fnando/password_strength"
  s.summary               = "Check password strength against several rules. Includes ActiveRecord/ActiveModel support."
  s.description           = s.summary
  s.license               = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activemodel"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-utils"
end
