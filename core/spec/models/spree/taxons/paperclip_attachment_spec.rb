# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Spree::Taxon::PaperclipAttachment", type: :model do
  describe "#destroy_attachment" do
    let(:taxon) { create(:taxon) }

    context "when trying to destroy a valid attachment definition" do
      context "and taxon has a file attached " do
        it "removes the attachment" do
          taxon.update(icon: File.new(Rails.root.join('..', '..', 'spec', 'fixtures', 'thinking-cat.jpg')))
          expect(taxon.destroy_attachment(:icon)).to be_truthy
        end
      end
      context "and the taxon does not have any file attached yet" do
        it "returns false" do
          expect(taxon.destroy_attachment(:icon)).to be_falsey
        end
      end
    end

    context "when trying to destroy an invalid attachment" do
      it 'returns false' do
        expect(taxon.destroy_attachment(:foo)).to be_falsey
      end
    end
  end
end
