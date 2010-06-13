# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "rubybuf/version"

Gem::Specification.new do |s|
  s.name        = "rubybuf"
  s.version     = Rubybuf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrey Lepeshkin"]
  s.email       = ["lilipoper@gmail.com"]
  s.summary     = "Rubybuf is google protocol buffers implementation in ruby."
  s.description = "Rubybuf is google protocol buffers implementation in ruby."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency(%q<rspec>, ["= 1.3.0"])
  s.add_development_dependency(%q<mocha>, ["= 0.9.8"])

  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end