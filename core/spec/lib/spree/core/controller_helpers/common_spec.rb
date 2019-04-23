# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ControllerHelpers::Common, type: :controller do
  controller(ApplicationController) do
    include Spree::Core::ControllerHelpers::Common
  end

  context "plural_resource_name" do
    let(:plural_config) { Spree::I18N_GENERIC_PLURAL }
    let(:base_class) { Spree::Product }

    subject { controller.plural_resource_name base_class }

    it "uses ActiveModel::Naming module to pluralize model names" do
      expect(subject).to eq base_class.model_name.human(count: plural_config)
    end

    it "uses the Spree::I18N_GENERIC_PLURAL constant" do
      expect(base_class.model_name).to receive(:human).with(hash_including(count: plural_config))
      subject
    end
  end
end
