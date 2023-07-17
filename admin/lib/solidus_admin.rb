# frozen_string_literal: true

require 'solidus_core'
require 'solidus_backend'
require 'solidus_admin/version'
require 'solidus_admin/engine'

require 'importmap-rails'
require 'tailwindcss-rails'
require 'turbo-rails'
require 'stimulus-rails'

module SolidusAdmin
  singleton_class.attr_accessor :importmap

  self.importmap = Importmap::Map.new
end
