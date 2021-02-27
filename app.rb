require 'bundler/setup'
Bundler.require
require './src/line'

get '/' do
    'true'
end