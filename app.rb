require 'bundler/setup'
Bundler.require
require './src/line'
Dotenv.load

get '/' do
    'true'
end