# frozen_string_literal: true

module SolidusAdmin::Moveable
  extend ActiveSupport::Concern

  included do
    before_action :load_moveable, only: [:move]
  end

  def move
    @moveable.insert_at(params.require(:position).to_i)

    respond_to do |format|
      format.js { head :no_content }
    end
  end

  private

  def load_moveable
    @moveable = moveable_class.find(params.require(:id))
    authorize! action_name, @moveable
  end

  def moveable_class
    "Spree::#{self.class.name.demodulize.remove("Controller").singularize}".constantize
  rescue NameError
    raise NameError,
      "could not infer model class from #{self.class.name}. Please override `moveable_class` to specify it explicitly."
  end
end
