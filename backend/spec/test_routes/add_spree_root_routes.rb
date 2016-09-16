Spree::Core::Engine.routes.draw do
  root to: lambda { |env| [200, {'Content-Type'  => 'text/plain'}, ["Home page"]] }
end
