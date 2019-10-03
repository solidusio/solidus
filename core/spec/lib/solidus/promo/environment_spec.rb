# frozen_string_literal: true

require 'spec_helper'
require 'solidus/core/environment/promotions'
require 'solidus/promo/environment'

RSpec.describe 'Solidus::Promo::Environment' do
  it 'is deprecated' do
    expect(Solidus::Deprecation).to receive(:warn)

    Solidus::Promo::Environment.new
  end

  context 'when customized' do
    after do
      # This is needed to cleanup classes after the following specs run.
      # They will add two new methods but we don't want them to be defined
      # on the described class for specs that will run later.
      Solidus::Core::Environment::Promotions.remove_method :custom_rules, :custom_rules=
    end

    context 'with class_eval' do
      it 'raises a deprecation warning but keep changes' do
        expect(Solidus::Deprecation).to receive(:warn)

        Solidus::Promo::Environment.class_eval do
          add_class_set :custom_rules
        end

        promo_environment_instance = Solidus::Core::Environment::Promotions.new
        expect(promo_environment_instance).to respond_to(:custom_rules)
        expect(promo_environment_instance).to respond_to(:custom_rules=)
      end
    end

    context 'with prepend' do
      it 'raises a deprecation warning but keep changes' do
        expect(Solidus::Deprecation).to receive(:warn)

        module CustomRules
          def self.prepended(base)
            base.add_class_set :custom_rules
          end
        end
        Solidus::Promo::Environment.prepend CustomRules

        promo_environment_instance = Solidus::Core::Environment::Promotions.new
        expect(promo_environment_instance).to respond_to(:custom_rules)
        expect(promo_environment_instance).to respond_to(:custom_rules=)
      end
    end
  end
end
