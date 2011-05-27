require 'rubygems'
require 'sinatra'
require 'bundler'
Bundler.require
require "#{Dir.pwd}/app.rb" 

root_dir = File.dirname(__FILE__).expand_path.to_s

set :run, false
set :environment, :production
set :root,  root_dir
set :app_file, File.join(root_dir, 'service.rb')
disable :run

FileUtils.mkdir_p "#{Dir.pwd}/log" unless File.exists?("#{Dir.pwd}/log")
log = File.new("log/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application
