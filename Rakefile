require "rubygems"
require "rake"
require "rake/rdoctask"
require "spec/rake/spectask"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rubybuf/version"

task :build do
  system "gem build rubybuf.gemspec"
end

task :install => :build do
  system "sudo gem install rubybuf-#{Rubybuf::VERSION}.gem"
end

task :release => :build do
  system "gem push rubybuf-#{Rubybuf::VERSION}.gem"
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
  spec.spec_opts = ["--options", "spec/spec.opts"]
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << "lib" << "spec"
  spec.pattern = "spec/**/*_spec.rb"
  spec.spec_opts = ["--options", "spec/spec.opts"]
  spec.rcov = true
end

task :default => ["spec"]