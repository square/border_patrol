require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'
require 'spec/rake/spectask'


Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.libs << 'spec'
  spec.spec_opts = ["--options", "spec/spec.opts"]
end

task :default => :spec
