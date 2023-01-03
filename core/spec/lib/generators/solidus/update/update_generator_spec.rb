# frozen_string_literal: true

require 'rails_helper'
require 'generators/solidus/update/update_generator'

RSpec.describe Solidus::UpdateGenerator do
  let(:initializer_directory) { Rails.root.join('tmp') }
  let(:initializer) { File.join(initializer_directory, 'new_solidus_defaults.rb') }
  let(:delete_initializer) { proc { File.delete(initializer) if File.exist?(initializer) } }
  let(:invoke) do
    lambda do |from, to|
      Rails::Generators.invoke('solidus:update', [
        "--initializer_directory=#{Rails.root.join('tmp')}",
        "--previous_version_prompt=false",
        "--from=#{from}",
        "--to=#{to}",
        "--quiet"
      ])
    end
  end

  before { delete_initializer.call }
  after { delete_initializer.call }

  context 'core' do
    it 'adds changes when present' do
      config_class = Class.new(Spree::Preferences::Configuration) do
        versioned_preference :foo, :boolean, initial_value: true, boundaries: { '3.0' => false }
      end
      stub_const('Spree::AppConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree.config do |config|
            config.load_defaults('2.0')
            # config.foo = false
          end
        RUBY
      )
    end

    it "informs about no changes if there're none" do
      config_class = Class.new(Spree::Preferences::Configuration)
      stub_const('Spree::AppConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree.config do |config|
            # No changes
          end
        RUBY
      )
    end
  end

  context 'frontend' do
    before { stub_const('Spree::Frontend::Engine', true) }

    it 'adds changes when present' do
      config_class = Class.new(Spree::Preferences::Configuration) do
        versioned_preference :foo, :boolean, initial_value: true, boundaries: { '3.0' => false }
      end
      stub_const('Spree::FrontendConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree::Frontend::Config.configure do |config|
            config.load_defaults('2.0')
            # config.foo = false
          end
        RUBY
      )
    end

    it "informs about no changes if there're none" do
      config_class = Class.new(Spree::Preferences::Configuration)
      stub_const('Spree::FrontendConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree::Frontend::Config.configure do |config|
            # No changes
          end
        RUBY
      )
    end
  end

  context 'backend' do
    before { stub_const('Spree::Backend::Engine', true) }

    it 'adds changes when present' do
      config_class = Class.new(Spree::Preferences::Configuration) do
        versioned_preference :foo, :boolean, initial_value: true, boundaries: { '3.0' => false }
      end
      stub_const('Spree::BackendConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree::Backend::Config.configure do |config|
            config.load_defaults('2.0')
            # config.foo = false
          end
        RUBY
      )
    end

    it "informs about no changes if there're none" do
      config_class = Class.new(Spree::Preferences::Configuration)
      stub_const('Spree::BackendConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree::Backend::Config.configure do |config|
            # No changes
          end
        RUBY
      )
    end
  end

  context 'api' do
    before { stub_const('Spree::Api::Engine', true) }

    it 'adds changes when present' do
      config_class = Class.new(Spree::Preferences::Configuration) do
        versioned_preference :foo, :boolean, initial_value: true, boundaries: { '3.0' => false }
      end
      stub_const('Spree::ApiConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree::Api::Config.configure do |config|
            config.load_defaults('2.0')
            # config.foo = false
          end
        RUBY
      )
    end

    it "informs about no changes if there're none" do
      config_class = Class.new(Spree::Preferences::Configuration)
      stub_const('Spree::ApiConfiguration', config_class)

      invoke.('2.0', '3.0')

      expect(File.read(initializer)).to include(
        <<~RUBY
          Spree::Api::Config.configure do |config|
            # No changes
          end
        RUBY
      )
    end
  end
end

