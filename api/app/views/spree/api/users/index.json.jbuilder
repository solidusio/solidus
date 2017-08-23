json.users(@users) do |user|
  json.partial!("spree/api/users/user", user: user)
end
json.count(@users.count)
json.current_page(@users.current_page)
json.pages(@users.total_pages)
