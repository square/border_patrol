# encoding: utf-8

Gem::Specification.new do |s|
  s.name = "border_patrol"
  s.version = File.read("lib/VERSION").strip

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = "1.3.7"

  s.authors = ["Zach Brock", "Matt Wilson"]
  s.email = "eng@squareup.com"
  
  s.date = "2010-10-20"
  s.description = "Lets you import a KML file and then check if points are inside or outside the polygons the file defines."
  s.summary = "Import and query KML regions"
  s.homepage = "http://github.com/square/border_patrol"

  s.rdoc_options = ["--charset=UTF-8"]

  s.require_paths = ["lib"]
  root_files = %w(border_patrol.gemspec Rakefile README.markdown .gitignore Gemfile Gemfile.lock)
  s.files = Dir['{lib,spec}/**/*'] + root_files
  s.test_files = Dir['spec/**/*']

  s.add_dependency("nokogiri", "1.4.3.1")

  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", "~> 1.3.0")
  s.add_development_dependency("progressbar")
end
