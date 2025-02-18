# frozen_string_literal: true

class SolidusAdmin::Resources::BaseComponent < SolidusAdmin::BaseComponent
  def initialize(resource)
    @resource = resource
    instance_variable_set(:"@#{resource_name}", resource)
  end

  def back_url
    solidus_admin.send(:"#{plural_resource_name}_path")
  end

  def resource_name
    @resource.model_name.singular_route_key
  end

  def plural_resource_name
    @resource.model_name.route_key
  end
end
