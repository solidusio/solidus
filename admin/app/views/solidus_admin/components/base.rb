class SolidusAdmin::Components::Base
  include SolidusAdmin::Components::Helpers
  
  def initialize(view_context:, virtual_path:, locals: {})
    @view_context = view_context
    @virtual_path = virtual_path
    @locals = locals
  end

  attr_reader :view_context, :virtual_path, :locals

  def self.for(view_context:, virtual_path:)
    virtual_path.classify.constantize.new(virtual_path: virtual_path, view_context: view_context)
  end

  def method_missing(name, ...)
    if @view_context.respond_to?(name)
      @view_context.send(name, ...)
    else
      super
    end
  end
end