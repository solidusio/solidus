Solidus::Role.where(:name => "admin").first_or_create
Solidus::Role.where(:name => "user").first_or_create
