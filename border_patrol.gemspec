# encoding: utf-8

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'border_patrol/version'

Gem::Specification.new do |s|
  s.name = 'border_patrol'
  s.version = BorderPatrol::VERSION
  s.authors = ['Zach Brock', 'Matt Wilson']
  s.email = 'github@squareup.com'
  s.date = '2013-03-05'
  s.description = 'Check if points are inside or outside the region polygons in an imported KML file.'
  s.summary = 'Import and query KML regions'
  s.homepage = 'http://github.com/square/border_patrol'

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")

  s.add_runtime_dependency('nokogiri')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
end
