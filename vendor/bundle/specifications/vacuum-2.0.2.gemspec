# -*- encoding: utf-8 -*-
# stub: vacuum 2.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "vacuum".freeze
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hakan Ensari".freeze]
  s.date = "2017-08-05"
  s.description = "A wrapper to the Amazon Product Advertising API".freeze
  s.email = ["me@hakanensari.com".freeze]
  s.homepage = "https://github.com/hakanensari/vacuum".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new("> 2.0".freeze)
  s.rubygems_version = "2.6.14".freeze
  s.summary = "Amazon Product Advertising in Ruby".freeze

  s.installed_by_version = "2.6.14" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dig_rb>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<jeff>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<multi_xml>.freeze, ["~> 0.6.0"])
      s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_development_dependency(%q<vcr>.freeze, [">= 0"])
    else
      s.add_dependency(%q<dig_rb>.freeze, ["~> 1.0"])
      s.add_dependency(%q<jeff>.freeze, ["~> 1.0"])
      s.add_dependency(%q<multi_xml>.freeze, ["~> 0.6.0"])
      s.add_dependency(%q<appraisal>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_dependency(%q<vcr>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<dig_rb>.freeze, ["~> 1.0"])
    s.add_dependency(%q<jeff>.freeze, ["~> 1.0"])
    s.add_dependency(%q<multi_xml>.freeze, ["~> 0.6.0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<vcr>.freeze, [">= 0"])
  end
end
