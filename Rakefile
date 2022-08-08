# frozen_string_literal: true

require "rake/testtask"
require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

task default: %i[test rubocop]
