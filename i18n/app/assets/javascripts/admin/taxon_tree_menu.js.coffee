root = exports ? this

root.taxon_tree_menu = (obj, context) ->

  id = obj.attr("id")

  admin_base_url = Spree.url(Spree.routes.admin_taxonomy_taxons_path)

  edit_url = admin_base_url.clone()
  edit_url.setPath(edit_url.path() + '/' + id + "/edit");

  translation_url = admin_base_url.clone()

  translation_base_path = admin_base_url.path().replace(/taxons/, "translations")
  translation_base_path = translation_base_path.replace(/taxonomies/, "taxons")
  translation_base_path = translation_base_path.replace(/\d/, id)
  translation_url.setPath(translation_base_path);

  create:
    label: "<i class='icon-plus'></i> " + Spree.translations.add,
    action: (obj) -> context.create(obj)
  rename:
    label: "<i class='icon-pencil'></i> " + Spree.translations.rename,
    action: (obj) -> context.rename(obj)
  remove:
    label: "<i class='icon-trash'></i> " + Spree.translations.remove,
    action: (obj) -> context.remove(obj)
  edit:
    separator_before: true,
    label: "<i class='icon-edit'></i> " + Spree.translations.edit,
    action: (obj) -> window.location = edit_url.toString()
  translate:
    separator_before: true,
    label: "<i class='icon-flag'></i> " + Spree.translations.translations,
    action: (obj) -> window.location = translation_url.toString()
