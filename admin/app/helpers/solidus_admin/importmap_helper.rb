# frozen_string_literal: true

module SolidusAdmin::ImportmapHelper
  def javascript_solidus_admin_importmap_tags(entry_point = "solidus_admin/application", shim: false, importmap: SolidusAdmin.importmap)
    safe_join [
      javascript_inline_importmap_tag(importmap.to_json(resolver: self)),
      javascript_importmap_module_preload_tags(importmap),
      (javascript_importmap_shim_nonce_configuration_tag if shim),
      (javascript_importmap_shim_tag if shim),
      javascript_import_module_tag(entry_point)
    ].compact, "\n"
  end
end
