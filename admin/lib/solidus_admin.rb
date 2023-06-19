# frozen_string_literal: true

require 'spree_core'
require 'solidus_admin/version'
require 'solidus_admin/engine'

require 'importmap-rails'
require 'tailwindcss-rails'

module SolidusAdmin
  singleton_class.attr_accessor :importmap

  self.importmap = Importmap::Map.new
end
