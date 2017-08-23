json.return_authorizations(@return_authorizations) do |return_authorization|
  json.(return_authorization, *return_authorization_attributes)
end
json.count(@return_authorizations.count)
json.current_page(@return_authorizations.current_page)
json.pages(@return_authorizations.total_pages)
