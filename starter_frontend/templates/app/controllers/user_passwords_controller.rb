# frozen_string_literal: true

class UserPasswordsController < Devise::PasswordsController
  # Overridden due to bug in Devise.
  #   respond_with resource, location: new_session_path(resource_name)
  # is generating bad url /session/new.user
  #
  # overridden to:
  #   respond_with resource, location: login_path
  #
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    set_flash_message(:notice, :send_instructions) if is_navigational_format?

    if resource.errors.empty?
      respond_with resource, location: login_path
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  # Devise::PasswordsController allows for blank passwords.
  # Silly Devise::PasswordsController!
  # Fixes spree/spree#2190.
  def update
    if params[:spree_user][:password].blank?
      self.resource = resource_class.new
      resource.reset_password_token = params[:spree_user][:reset_password_token]
      set_flash_message(:error, :cannot_be_blank)
      render :edit
    else
      super
    end
  end

  protected

  def translation_scope
    'devise.user_passwords'
  end

  def new_session_path(resource_name)
    send("new_#{resource_name}_session_path")
  end
end
