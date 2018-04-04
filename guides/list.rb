#!/usr/bin/env ruby
# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

# Generates a new guides index
#
# Usage
#
#     ./index.rb > index.md
#
def generate_index(files)
  current_dir = nil

  puts "# Solidus Guides"
  puts ""

  files.each do |file|
    next unless File.file?(file)
    file_path = file.sub(/^\.\//, '')
    dir_name = nicify(File.dirname(file))
    file_name = nicify(File.basename(file))
    new_dir = current_dir != dir_name
    if new_dir && !current_dir
      puts "## #{dir_name}"
    elsif current_dir && new_dir
      puts ""
      puts "## #{dir_name}"
    end
    puts " - [#{file_name}](#{file_path})"
    current_dir = dir_name
  end
end

def nicify(name)
  name.sub(/^\.\//, '').tr('-', ' ').sub(/\.md$/, '').titleize
end

files = Dir.glob("**/*").sort.reject do |file|
  File.basename(file) == File.basename(__FILE__) || File.basename(file) == 'index.md'
end

generate_index(files)
