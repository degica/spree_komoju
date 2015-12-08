Spree::Core::Engine.routes.draw do
  post "komoju_webhook" => "komoju#callback"
end
