require 'bundler/setup'
Bundler.require
require './src/line.rb'

get '/' do
    'true'
end