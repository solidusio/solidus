# frozen_string_literal: true

module Spree
  module Api
    class ClassificationsController < Spree::Api::BaseController
      def update
        authorize! :update, Product
        authorize! :update, Taxon

        taxon = Spree::Taxon.find(params[:taxon_id])
        classification = taxon.classifications.find_by(product_id: params[:product_id])

        if classification.insert_at(params[:position].to_i)
          head :ok
        else
          render json: { errors: classification.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
