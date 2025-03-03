# frozen_string_literal: true

class SolidusAdmin::Stores::AddressForm::Component < SolidusAdmin::BaseComponent
  def initialize(store:)
    @name = "store"
    @store = store
  end

  def state_options
    country = @store.country
    return [] unless country && country.states_required

    country.states.pluck(:name, :id)
  end
end
