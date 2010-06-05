require 'rubygems'

gem "mocha", ">= 0.9.8"

require "rubybuf"
require "mocha"
require "spec"

Spec::Runner.configure do |config|
  config.mock_with :mocha
end