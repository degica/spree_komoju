module SpreeKomoju
  mattr_accessor :enable_customer_profiles
  mattr_accessor :komoju_webhook_secret_token

  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_komoju'

    initializer "spree.gateway.payment_methods", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::Gateway::KomojuCreditCard
      app.config.spree.payment_methods << Spree::Gateway::KomojuKonbini
      app.config.spree.payment_methods << Spree::Gateway::KomojuBankTransfer
      app.config.spree.payment_methods << Spree::Gateway::KomojuPayEasy
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      require "active_merchant/billing/gateways/komoju"
    end

    config.to_prepare &method(:activate).to_proc
  end
end
