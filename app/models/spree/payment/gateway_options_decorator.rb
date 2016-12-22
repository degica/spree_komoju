Spree::Payment::GatewayOptions.class_eval do
  prepend SpreeKomoju::GatewayOptionsWithHeaders
end
