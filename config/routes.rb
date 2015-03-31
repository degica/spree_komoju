Spree::Core::Engine.routes.draw do
  get "/komoju_webhook" => "komoju#callback"
end
