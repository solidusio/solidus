object false
node(:attributes) { [*user_attributes] }
node(:required_attributes) { required_fields_for(Solidus.user_class) }
