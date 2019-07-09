# frozen_string_literal: true

require 'spec_helper'
require 'spree/core/environment/promotions'
require 'spree/promo/environment'

RSpec.describe 'Spree::Promo::Environment' do
  it 'is deprecated' do
    expect(Spree::Deprecation).to receive(:warn)

    Spree::Promo::Environment.new
  end

  context 'when customized' do
    after do
      # This is needed to cleanup classes after the following specs run.
      # They will add two new methods but we don't want them to be defined
      # on the described class for specs that will run later.
      Spree::Core::Environment::Promotions.remove_method :custom_rules, :custom_rules=
    end

    context 'with class_eval' do
      it 'raises a deprecation warning but keep changes' do
        expect(Spree::Deprecation).to receive(:warn)

        Spree::Promo::Environment.class_eval do
          add_class_set :custom_rules
        end

        promo_environment_instance = Spree::Core::Environment::Promotions.new
        expect(promo_environment_instance).to respond_to(:custom_rules)
        expect(promo_environment_instance).to respond_to(:custom_rules=)
      end
    end

    context 'with prepend' do
      it 'raises a deprecation warning but keep changes' do
        expect(Spree::Deprecation).to receive(:warn)

        module CustomRules
          def self.prepended(base)
            base.add_class_set :custom_rules
          end
        end
        Spree::Promo::Environment.prepend CustomRules

        promo_environment_instance = Spree::Core::Environment::Promotions.new
        expect(promo_environment_instance).to respond_to(:custom_rules)
        expect(promo_environment_instance).to respond_to(:custom_rules=)
      end
    end
  end
end
