require 'spec_helper'

class FakesController < ApplicationController
  include Spree::Core::ControllerHelpers::StrongParameters
end

describe Spree::Core::ControllerHelpers::StrongParameters, type: :controller do
  controller(FakesController) {}

  describe '#base_attributes' do
    it 'returns Spree::PermittedAttributes::Base module' do
      expect(controller.base_attributes).to eq Spree::PermittedAttributes::Base
    end
  end

  describe '#admin_attributes' do
    it 'returns Spree::PermittedAttributes::Admin module' do
      expect(controller.admin_attributes).to eq Spree::PermittedAttributes::Admin
    end
  end

  describe '#permitted_payment_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_payment_attributes.class).to eq Array
    end
  end

  describe '#permitted_checkout_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_checkout_attributes.class).to eq Array
    end
  end

  describe '#permitted_order_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_order_attributes.class).to eq Array
    end
  end

  describe '#permitted_product_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_product_attributes.class).to eq Array
    end
  end

  describe '#permitted_line_item_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_line_item_attributes.class).to eq Array
    end
  end

  describe '#permitted_admin_line_item_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_admin_line_item_attributes.class).to eq Array
    end
  end

  describe '#permitted_admin_order_attributes' do
    it 'returns Array class' do
      expect(controller.permitted_admin_order_attributes.class).to eq Array
    end
  end
end
