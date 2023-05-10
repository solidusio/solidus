module SolidusAdmin::Components::Helpers
  def load_javascript!
    content_for(
      :page_components,
      javascript_tag(render(template: @virtual_path, formats: :js), type: :module)
    )
  end

  def stimulus_id
    @virtual_path.gsub(%r{/_?}, '--').tr('_', '-')
  end
end