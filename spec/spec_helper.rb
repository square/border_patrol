require 'rubygems'
require 'bundler'
Bundler.setup

require 'nokogiri'

base_dir = File.expand_path("#{File.dirname(__FILE__)}/..")
app_dirs = ['lib', 'lib/kaml_pen']

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

app_dirs.each do |app_dir|
  Dir["#{base_dir}/spec/#{app_dir}/*.rb"].each do |f|
    f.sub!('/spec','')
    f.sub!('_spec','')
    require f
  end
end

Spec::Runner.configure do |config|
end
