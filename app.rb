require 'bundler/setup'
Bundler.require
Dotenv.load
require './src/scrape'
require './src/line'

get '/' do
    'true'
end