# frozen_string_literal: true

DummyApp::Application.routes.draw do
  mount Solidus::Core::Engine, at: '/'
end
