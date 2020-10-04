# frozen_string_literal: true

require 'generators/solidus/install/install_generator'

module Spree
  # @private
  class InstallGenerator < Solidus::InstallGenerator
    def print_deprecation_warning
      puts " "
      puts "*" * 50
      puts "spree:install generator is deprecated, please use solidus:install."
      puts " "
    end
  end
end
