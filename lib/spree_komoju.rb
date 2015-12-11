require 'spree_core'
require 'spree_komoju/engine'

# This extension adds HTTP PATCH to ssl_request.
# This is needed for WebMoney multi-card in Komoju.
if ActiveMerchant::VERSION == "1.47.0"
  require 'ext/activemerchant/connection'
end
