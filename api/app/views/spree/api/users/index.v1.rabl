object false
child(@users => :users) do
  extends "spree/api/users/show"
end
node(:count) { @users.count }
node(:current_page) { @users.current_page }
node(:pages) { @users.total_pages }
