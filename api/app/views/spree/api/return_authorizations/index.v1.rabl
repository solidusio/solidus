object false
child(@return_authorizations => :return_authorizations) do
  attributes *return_authorization_attributes
end
node(:count) { @return_authorizations.count }
node(:current_page) { @return_authorizations.current_page }
node(:pages) { @return_authorizations.total_pages }
