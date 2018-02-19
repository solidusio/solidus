# frozen_string_literal: true

require 'factory_bot'

Dir["#{File.dirname(__FILE__)}/factories/**"].each do |f|
  require File.expand_path(f)
end
