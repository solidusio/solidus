# frozen_string_literal: true

DummyApp::Application.routes.draw do
  mount Spree::Core::Engine, at: '/'
end
