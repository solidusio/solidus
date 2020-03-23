# frozen_string_literal: true

require 'spec_helper'

feature 'Promotions' do
  stub_authorization!

  context 'index' do
    context 'when no promotions' do
      scenario 'shows no promotions found message' do
        visit spree.admin_promotions_path
        expect(page).to have_content('No Promotions found.')
      end
    end

    context 'when promotion is active' do
      given!(:promotion) { create :promotion }

      scenario 'promotion status is active' do
        visit spree.admin_promotions_path

        within_row(1) do
          expect(column_text(3)).to eq("Active")
        end
      end
    end

    context 'when promotion is in the future' do
      given!(:promotion) { create :promotion, starts_at: 1.day.after }

      scenario 'promotion status is not started' do
        visit spree.admin_promotions_path

        within_row(1) do
          expect(column_text(3)).to eq("Not started")
        end
      end
    end

    context 'when promotion is in the past' do
      given!(:promotion) { create :promotion, expires_at: 1.day.ago }

      scenario 'promotion status is expired' do
        visit spree.admin_promotions_path

        within_row(1) do
          expect(column_text(3)).to eq("Expired")
        end
      end
    end
  end
end
