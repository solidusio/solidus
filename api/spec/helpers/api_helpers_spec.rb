# frozen_string_literal: true

RSpec.describe Spree::Api::ApiHelpers, type: :helper do
  describe 'attributes access' do
    Spree::Api::ApiHelpers::ATTRIBUTES.each do |attribute|
      it "warns about deprecated access for #{attribute}" do
        expect(Spree::Deprecation).to receive(:warn).
          with("Please use Spree::Api::Config::#{attribute} instead.")

        expect(Spree::Api::ApiHelpers.send(attribute)).to eq(
          Spree::Api::Config.send(attribute)
        )
      end
    end
  end
end

