# frozen_string_literal: true

require 'spec_helper'
require 'spree/event/adapters/deprecation_handler'
require 'spree/event/adapters/default'

module Spree
  module Event
    module Adapters
      RSpec.describe DeprecationHandler do
        let(:env_key) { described_class::CI_LEGACY_ADAPTER_ENV_KEY }

        let(:reset_env_key) do
          lambda do |example|
            old_value = ENV[env_key]
            example.run
            ENV[env_key] = old_value
          end
        end

        describe '#legacy_adapter?' do
          context 'when the events adapter is the legacy' do
            it 'returns true' do
              expect(described_class.legacy_adapter?(ActiveSupportNotifications)).to be(true)
            end
          end

          context 'when the events adapter is not the legacy' do
            it 'returns false' do
              expect(described_class.legacy_adapter?(Default.new)).to be(false)
            end
          end
        end

        describe '#legacy_adapter_set_by_env' do
          around { |example| reset_env_key.(example) }

          context 'when env var is set' do
            it 'returns the legacy adapter' do
              ENV[env_key] = '1'

              expect(described_class.legacy_adapter_set_by_env).to be(ActiveSupportNotifications)
            end
          end

          context 'when env var is not set' do
            it 'returns nil' do
              ENV[env_key] = nil

              expect(described_class.legacy_adapter_set_by_env).to be(nil)
            end
          end
        end

        describe '#render_deprecation_message?' do
          context 'when adapter is legacy and is not set by env' do
            around { |example| reset_env_key.(example) }

            it 'returns true' do
              ENV[env_key] = nil

              expect(described_class.render_deprecation_message?(ActiveSupportNotifications)).to be(true)
            end
          end

          context 'when adapter is legacy and is set by env' do
            around { |example| reset_env_key.(example) }

            it 'returns true' do
              ENV[env_key] = '1'

              expect(described_class.render_deprecation_message?(ActiveSupportNotifications)).to be(false)
            end
          end

          context 'when adapter is not legacy' do
            it 'returns false' do
              expect(described_class.render_deprecation_message?(Default.new)).to be(false)
            end
          end
        end
      end
    end
  end
end
