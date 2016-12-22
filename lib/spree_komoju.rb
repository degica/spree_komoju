require 'spree_core'
require 'spree_komoju/engine'
require 'spree_komoju/errors'
require 'spree_komoju/controller_helpers'
require 'spree_komoju/gateway_options_with_headers'
require 'spree_komoju/callbacks/callback'
require 'spree_komoju/callbacks/captured'
require 'spree_komoju/callbacks/refunded'

# This extension adds HTTP PATCH to ssl_request.
# This is needed for WebMoney multi-card in Komoju.
if ActiveMerchant::VERSION == "1.47.0"
  require 'ext/activemerchant/connection'
end
