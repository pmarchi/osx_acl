# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{osx_acl}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Patrick Marchi"]
  s.date = %q{2011-06-02}
  s.default_executable = %q{acl}
  s.email = %q{mail@patrickmarchi.ch}
  s.executables = ["acl"]
  s.files = ["README", "bin/acl", "lib/osx_acl", "lib/osx_acl/dir.rb", "lib/osx_acl/script.rb", "lib/osx_acl.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simplify the management of ACLs on OS X, by restricting operation to common tasks.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
