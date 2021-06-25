# frozen_string_literal: true

require 'spec_helper'
require 'spree/core'

RSpec.describe Spree::Core do
  it 'loads only the necessary Rails Frameworks' do
    aggregate_failures do
      expect(defined? ActionCable::Engine).to be_falsey
      expect(defined? ActionController::Railtie).to be_truthy
      expect(defined? ActionMailer::Railtie).to be_truthy
      expect(defined? ActionView::Railtie).to be_truthy
      expect(defined? ActiveJob::Railtie).to be_truthy
      expect(defined? ActiveModel::Railtie).to be_truthy
      expect(defined? ActiveRecord::Railtie).to be_truthy
      expect(defined? ActiveStorage::Engine).to be_truthy
      expect(defined? Rails::TestUnit::Railtie).to be_falsey
      expect(defined? Sprockets::Railtie).to be_truthy
    end
  end

  describe '.load_defaults' do
    it 'load defaults for all available components' do
      config_instance_builder = -> { Class.new(Spree::Preferences::Configuration).new }
      core = stub_const('Spree::Config', config_instance_builder.() )
      frontend = stub_const('Spree::Frontend::Config', config_instance_builder.() )
      backend = stub_const('Spree::Backend::Config', config_instance_builder.() )
      api = stub_const('Spree::Api::Config', config_instance_builder.() )

      expect(core).to receive(:load_defaults).with(Spree.solidus_version)
      expect(frontend).to receive(:load_defaults).with(Spree.solidus_version)
      expect(backend).to receive(:load_defaults).with(Spree.solidus_version)
      expect(api).to receive(:load_defaults).with(Spree.solidus_version)

      Spree.load_defaults(Spree.solidus_version)
    end
  end
end
