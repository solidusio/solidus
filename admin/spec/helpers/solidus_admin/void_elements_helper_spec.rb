# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::VoidElementsHelper, type: :helper do
  describe '#void_element?' do
    subject { helper.void_element?(element) }

    context 'when element is void' do
      let(:element) { :input }

      it { is_expected.to be true }
    end

    context 'when element is not void' do
      let(:element) { :div }

      it { is_expected.to be false }
    end
  end
end
