object @user

attributes *user_attributes
child(:bill_address => :bill_address) do
  extends "solidus/api/addresses/show"
end

child(:ship_address => :ship_address) do
  extends "solidus/api/addresses/show"
end