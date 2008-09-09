class AddressesController < Admin::BaseController
  before_filter :check_existing, :only => :new
  before_filter :load_data
  layout 'application'
  resource_controller :singleton
  
  belongs_to :order, :polymorphic => true
  
  create.response do |wants|
    wants.html do 
      next_step
    end
  end
  
  update.response do |wants|
    wants.html do 
      next_step
    end
  end
  
  def country_changed
    render :partial => "states"
  end
  
  private
  def load_data
    load_object
 
    @selected_country_id = params[:address][:country_id].to_i if params.has_key?('address')
    @selected_country_id ||= @order.address.country_id unless @order.nil? || @order.address.nil?  
    @selected_country_id ||= Spree::Config[:default_country_id]

    @states = State.find_all_by_country_id(@selected_country_id, :order => 'name')  
    @countries = Country.find(:all)
  end
  
  def next_step
    @order.next!
    redirect_to checkout_order_url(@order)
  end
  
  def check_existing
    redirect_to edit_order_address_url if parent_object.address 
  end
  
end